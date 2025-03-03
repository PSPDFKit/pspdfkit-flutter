/*
 * Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit.document

import android.util.Log
import com.pspdfkit.annotations.Annotation
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.document.formatters.DocumentJsonFormatter
import com.pspdfkit.document.formatters.XfdfFormatter
import com.pspdfkit.flutter.pspdfkit.AnnotationTypeAdapter
import com.pspdfkit.flutter.pspdfkit.api.DocumentSaveOptions
import com.pspdfkit.flutter.pspdfkit.api.PageInfo
import com.pspdfkit.flutter.pspdfkit.api.PdfDocumentApi
import com.pspdfkit.flutter.pspdfkit.api.PdfVersion
import com.pspdfkit.flutter.pspdfkit.api.PspdfkitApiError
import com.pspdfkit.flutter.pspdfkit.forms.FormHelper
import com.pspdfkit.flutter.pspdfkit.util.DocumentJsonDataProvider
import com.pspdfkit.flutter.pspdfkit.util.Preconditions.requireNotNullNotEmpty
import com.pspdfkit.flutter.pspdfkit.util.areValidIndexes
import com.pspdfkit.forms.ChoiceFormElement
import com.pspdfkit.forms.EditableButtonFormElement
import com.pspdfkit.forms.SignatureFormElement
import com.pspdfkit.forms.TextFormElement
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.schedulers.Schedulers
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.nio.charset.StandardCharsets
import java.util.EnumSet

class FlutterPdfDocument(
    private val pdfDocument: PdfDocument
) : PdfDocumentApi {

    private var disposable: Disposable? = null
    private val documentPermissionsMap = mapOf(
        "print" to com.pspdfkit.document.DocumentPermissions.PRINTING,
        "modification" to com.pspdfkit.document.DocumentPermissions.MODIFICATION,
        "fillForms" to com.pspdfkit.document.DocumentPermissions.FILL_FORMS,
        "assemble" to com.pspdfkit.document.DocumentPermissions.ASSEMBLE,
        "extractAccessibility" to com.pspdfkit.document.DocumentPermissions.EXTRACT_ACCESSIBILITY,
        "extract" to com.pspdfkit.document.DocumentPermissions.EXTRACT,
        "annotationsAndForms" to com.pspdfkit.document.DocumentPermissions.ANNOTATIONS_AND_FORMS,
        "printHighQuality" to com.pspdfkit.document.DocumentPermissions.PRINT_HIGH_QUALITY,
    )

    private val pdfVersionMap = mapOf(
        PdfVersion.PDF_1_0 to com.pspdfkit.document.PdfVersion.PDF_1_0,
        PdfVersion.PDF_1_1 to com.pspdfkit.document.PdfVersion.PDF_1_1,
        PdfVersion.PDF_1_2 to com.pspdfkit.document.PdfVersion.PDF_1_2,
        PdfVersion.PDF_1_3 to com.pspdfkit.document.PdfVersion.PDF_1_3,
        PdfVersion.PDF_1_4 to com.pspdfkit.document.PdfVersion.PDF_1_4,
        PdfVersion.PDF_1_5 to com.pspdfkit.document.PdfVersion.PDF_1_5,
        PdfVersion.PDF_1_6 to com.pspdfkit.document.PdfVersion.PDF_1_6,
        PdfVersion.PDF_1_7 to com.pspdfkit.document.PdfVersion.PDF_1_7,
    )

    override fun getPageInfo(pageIndex: Long, callback: (Result<PageInfo>) -> Unit) {
        val width = pdfDocument.getPageSize(pageIndex.toInt()).width
        val height = pdfDocument.getPageSize(pageIndex.toInt()).height
        val label = pdfDocument.getPageLabel(pageIndex.toInt(), false)
        val rotation = pdfDocument.getPageRotation(pageIndex.toInt())
        val pageInfo =
            PageInfo(pageIndex, height.toDouble(), width.toDouble(), rotation.toLong(), label)
        callback(Result.success(pageInfo))
    }

    override fun exportPdf(options: DocumentSaveOptions?, callback: (Result<ByteArray>) -> Unit) {
        val fileUrl = pdfDocument.documentSource.fileUri?.path
        if (fileUrl == null) {
            callback(Result.failure(Exception("Document source is not a file")))
            return
        }
        val data: ByteArray = fileUrl.let { File(it).readBytes() }
        callback(Result.success(data))
    }

    override fun getFormField(fieldName: String, callback: (Result<Map<String, Any?>>) -> Unit) {
        try {
            val formField = pdfDocument.formProvider.getFormFieldWithFullyQualifiedName(fieldName)
            if (formField == null) {
                callback(Result.failure(Exception("Form field not found")))
                return
            }
            val formFieldData = FormHelper.formFieldPropertiesToMap(listOf(formField))
            callback(Result.success(formFieldData.first()))
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }

    override fun getFormFields(callback: (Result<List<Map<String, Any?>>>) -> Unit) {
        try {
            val formFields = pdfDocument.formProvider.formFields
            val formFieldData = FormHelper.formFieldPropertiesToMap(formFields)
            callback(Result.success(formFieldData))
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }

    override fun setFormFieldValue(
        value: String,
        fullyQualifiedName: String,
        callback: (Result<Boolean?>) -> Unit
    ) {
        // noinspection checkResult
        pdfDocument.formProvider
            .getFormElementWithNameAsync(fullyQualifiedName)
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { formElement ->
                    if (formElement is TextFormElement) {
                        formElement.setText(value)
                        callback(Result.success(true))
                    } else if (formElement is EditableButtonFormElement) {
                        when (value) {
                            "selected" -> {
                                formElement.select()
                                callback(Result.success(true))
                            }

                            "deselected" -> {
                                formElement.deselect()
                                callback(Result.success(true))
                            }

                            else -> {
                                callback(
                                    Result.failure(
                                        PspdfkitApiError(
                                            "Invalid value for editable button form element",
                                            "Value must be either \"selected\" or \"deselected\""
                                        )
                                    )
                                )
                            }
                        }
                    } else if (formElement is ChoiceFormElement) {
                        val selectedIndexes: List<Int> = java.util.ArrayList<Int>()
                        if (areValidIndexes(value, selectedIndexes.toMutableList())) {
                            formElement.selectedIndexes = selectedIndexes
                            callback(Result.success(true))
                        } else {
                            callback(
                                Result.failure(
                                    PspdfkitApiError(
                                        "Invalid value for choice form element",
                                        "\"value\" argument needs a list of " +
                                                "integers to set selected indexes for a choice " +
                                                "form element (e.g.: \"1, 3, 5\").",
                                    )
                                )
                            )
                        }
                    } else if (formElement is SignatureFormElement) {
                        callback(
                            Result.failure(
                                PspdfkitApiError(
                                    "Signature form elements cannot be set programmatically",
                                    "Signature form elements are not supported.",
                                )
                            )
                        )
                    } else {
                        callback(
                            Result.failure(
                                PspdfkitApiError(
                                    "Invalid form element type",
                                    "Form element with name $fullyQualifiedName is not a text, " +
                                            "editable button, choice, or signature form element."
                                )
                            )
                        )
                    }
                },
                { throwable ->
                    callback(
                        Result.failure(
                            PspdfkitApiError(
                                "Error while searching for a form element with name $fullyQualifiedName",
                                throwable.message ?: "",
                            )
                        )
                    )
                }
            ) // Form element for the given name not found.
            { callback(Result.failure(PspdfkitApiError("Form element not found", ""))) }
    }

    override fun getFormFieldValue(
        fullyQualifiedName: String,
        callback: (Result<String?>) -> Unit
    ) {
        disposable = pdfDocument.formProvider
            .getFormElementWithNameAsync(fullyQualifiedName)
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { formElement ->
                    when (formElement) {
                        is TextFormElement -> {
                            val text: String = formElement.text ?: ""
                            callback(Result.success(text))
                        }

                        is EditableButtonFormElement -> {
                            val isSelected: Boolean =
                                formElement.isSelected
                            callback(Result.success(if (isSelected) "selected" else "deselected"))
                        }

                        is ChoiceFormElement -> {
                            val selectedIndexes: List<Int> =
                                formElement.selectedIndexes
                            val stringBuilder = StringBuilder()
                            val iterator = selectedIndexes.iterator()
                            while (iterator.hasNext()) {
                                stringBuilder.append(iterator.next())
                                if (iterator.hasNext()) {
                                    stringBuilder.append(",")
                                }
                            }
                            callback(Result.success(stringBuilder.toString()))
                        }

                        is SignatureFormElement -> {
                            callback(
                                Result.failure(
                                    PspdfkitApiError(
                                        "Signature form elements cannot be read programmatically",
                                        "Signature form elements are not supported.",
                                    )
                                )
                            )
                        }

                        else -> {
                            callback(
                                Result.failure(
                                    PspdfkitApiError(
                                        "Invalid form element type",
                                        "Form element with name $fullyQualifiedName is not a text, " +
                                                "editable button, choice, or signature form element."
                                    )
                                )
                            )
                        }
                    }
                },
                { throwable ->
                    callback(
                        Result.failure(
                            PspdfkitApiError(
                                "Error while searching for a form element with name $fullyQualifiedName",
                                throwable.message ?: "",
                            )
                        )
                    )
                }
            ) // Form element for the given name not found.
            {
                callback(
                    Result.failure(
                        PspdfkitApiError(
                            "Form field not found.",
                            "Form element with name $fullyQualifiedName not found"
                        )
                    )
                )
            }
    }

    override fun applyInstantJson(annotationsJson: String, callback: (Result<Boolean?>) -> Unit) {
        val documentJsonDataProvider = DocumentJsonDataProvider(
            requireNotNullNotEmpty(
                annotationsJson,
                "annotationsJson"
            )
        )
        // noinspection checkResult
        DocumentJsonFormatter.importDocumentJsonAsync(pdfDocument, documentJsonDataProvider)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                {
                    callback(Result.success(true))
                }
            ) { throwable ->
                callback(
                    Result.failure(
                        PspdfkitApiError(
                            "Failed to apply Instant JSON",
                            throwable.message ?: "",
                        )
                    )
                )
            }
    }

    override fun exportInstantJson(callback: (Result<String?>) -> Unit) {
        val outputStream = ByteArrayOutputStream()

        // noinspection checkResult
        DocumentJsonFormatter.exportDocumentJsonAsync(pdfDocument, outputStream)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                {
                    callback(Result.success(outputStream.toString(StandardCharsets.UTF_8.name())))
                }
            ) { throwable ->
                callback(
                    Result.failure(
                        PspdfkitApiError(
                            "Failed to export Instant JSON",
                            throwable.message ?: "",
                        )
                    )
                )
            }
    }

    override fun addAnnotation(
        jsonAnnotation: String,
        attachment:Any?,
        callback: (Result<Boolean?>) -> Unit
    ) {
        disposable =
            pdfDocument.annotationProvider.createAnnotationFromInstantJsonAsync(jsonAnnotation)
                .subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                    {
                        callback(Result.success(true))
                    }
                ) { throwable ->
                    callback(
                        Result.failure(
                            PspdfkitApiError(
                                "Error while creating annotation",
                                throwable.message ?: "",
                            )
                        )
                    )
                }
    }

    override fun updateAnnotation(jsonAnnotation: String, callback: (Result<Boolean?>) -> Unit) {
        try {
          removeAnnotation(jsonAnnotation) { it ->
                if (it.isSuccess) {
                    addAnnotation(jsonAnnotation, null) {
                        callback(it)
                    }
                } else {
                    callback(it)
                }
            }
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }

    override fun removeAnnotation(jsonAnnotation: String, callback: (Result<Boolean?>) -> Unit) {
        try {
            val annotationObject = JSONObject(jsonAnnotation).toMap()

            // Get name or UUID
            val name = annotationObject["name"] as? String?
            val uuid = annotationObject["id"] as? String?

            if (name == null && uuid == null) {
                callback(Result.failure(Exception("Annotation has no identifier (name or uuid)")))
                return
            }

            val pageIndex = (annotationObject["pageIndex"] as Number).toInt()
            val allAnnotations = pdfDocument.annotationProvider.getAnnotations(pageIndex)

            // First try to find by name, then by UUID if available
            val annotation = if (name != null) {
                allAnnotations.firstOrNull { it.name == name }
            } else if (uuid != null) {
                allAnnotations.firstOrNull { it.uuid == uuid }
            } else {
                null
            }

            if (annotation == null) {
                callback(Result.failure(Exception("Annotation not found")))
                return
            }
            pdfDocument.annotationProvider.removeAnnotationFromPage(annotation)
            callback(Result.success(true))
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }

    override fun getAnnotations(pageIndex: Long, type: String, callback: (Result<Any>) -> Unit) {

        val annotationJsonList = ArrayList<String>()
        // noinspection checkResult
        pdfDocument.annotationProvider.getAllAnnotationsOfTypeAsync(
            AnnotationTypeAdapter.fromString(
                type
            ),
            pageIndex.toInt(), 1
        )
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { annotation ->
                    annotationJsonList.add(annotation.toInstantJson())
                },
                { throwable ->
                    callback(
                        Result.failure(
                            PspdfkitApiError(
                                "Error while retrieving annotation of type $type",
                                throwable.message ?: "",
                            )
                        )
                    )
                },
                {
                    callback(Result.success(annotationJsonList))
                }
            )
    }

    override fun getAllUnsavedAnnotations(callback: (Result<Any>) -> Unit) {
        val outputStream = ByteArrayOutputStream()
        disposable = DocumentJsonFormatter.exportDocumentJsonAsync(pdfDocument, outputStream)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe({
                val jsonString: String = outputStream.toString()
                callback(Result.success(jsonString))
            }, { throwable ->
                callback(
                    Result.failure(
                        PspdfkitApiError(
                            "Error while getting unsaved JSON annotations.",
                            throwable.message ?: "",
                        )
                    )
                )
            })
    }

    override fun importXfdf(xfdfString: String, callback: (Result<Boolean>) -> Unit) {
        val dataProvider = DocumentJsonDataProvider(xfdfString)
        // The async parse method is recommended (so you can easily offload parsing from the UI thread).
        disposable = XfdfFormatter.parseXfdfAsync(pdfDocument, dataProvider)
            .subscribeOn(Schedulers.io()) // Specify the thread on which to parse XFDF.
            .subscribe { annotations ->
                // Annotations parsed from XFDF aren't added to the document automatically.
                // You need to add them manually.
                for (annotation in annotations) {
                    pdfDocument.annotationProvider.addAnnotationToPage(annotation)
                }
            }
    }

    override fun exportXfdf(xfdfPath: String, callback: (Result<Boolean>) -> Unit) {
        // Output stream pointing to the XFDF file into which to write the data.
        val outputStream = FileOutputStream(xfdfPath)

        // The async `write` method is recommended (so you can easily offload writing from the UI thread).
        disposable = XfdfFormatter.writeXfdfAsync(
            pdfDocument,
            listOf(),
            listOf(),
            outputStream
        )
            .subscribeOn(Schedulers.io()) // Specify the thread on which to write XFDF.
            .subscribe(
                {
                    // XFDF was successfully written.
                    callback(Result.success(true))
                },
                { throwable ->
                    // An error occurred while writing XFDF.
                    callback(
                        Result.failure(
                            PspdfkitApiError(
                                "Error while exporting XFDF",
                                throwable.message ?: "",
                            )
                        )
                    )
                }
            )
    }

    override fun save(
        outputPath: String?,
        options: DocumentSaveOptions?,
        callback: (Result<Boolean>) -> Unit
    ) {

        if (outputPath != null && options != null) {
            // noinspection checkResult
            pdfDocument.saveIfModifiedAsync(
                outputPath,
                convertDocumentSaveOptions(options)
            )
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                    {
                        callback(Result.success(true))
                    }
                ) { throwable ->
                    callback(
                        Result.failure(
                            PspdfkitApiError(
                                "Error while saving document",
                                throwable.message ?: "",
                            )
                        )
                    )
                }
        } else if (outputPath != null) {
            disposable = pdfDocument.saveAsync(outputPath)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                    {
                        callback(Result.success(true))
                    }
                ) { throwable ->
                    callback(
                        Result.failure(
                            PspdfkitApiError(
                                "Error while saving document",
                                throwable.message ?: "",
                            )
                        )
                    )
                }

        } else {
            // noinspection checkResult
            pdfDocument.saveIfModifiedAsync()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                    {
                        callback(Result.success(true))
                    }
                ) { throwable ->
                    callback(
                        Result.failure(
                            PspdfkitApiError(
                                "Error while saving document",
                                throwable.message ?: "",
                            )
                        )
                    )
                }
        }
    }

    override fun getPageCount(callback: (Result<Long>) -> Unit) {
        try {
            callback(Result.success(pdfDocument.pageCount.toLong()))
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }

    fun dispose() {
        disposable?.dispose()
    }

    private fun convertDocumentSaveOptions(options: DocumentSaveOptions): com.pspdfkit.document.DocumentSaveOptions {
        return com.pspdfkit.document.DocumentSaveOptions(
            options.userPassword,
            options.permissions?.map { documentPermissionsMap[it?.name] }?.let {
                EnumSet.copyOf(it)
            },
            options.incremental ?: false,
            pdfVersionMap[options.pdfVersion]
        )
    }
}

fun JSONObject.toMap(): Map<String, Any> {
    val map = mutableMapOf<String, Any>()
    val keys = this.keys()
    while (keys.hasNext()) {
        val key = keys.next()
        var value = this.get(key)

        if (value is JSONObject) {
            value = value.toMap()
        }

        map[key] = value
    }
    return map
}
