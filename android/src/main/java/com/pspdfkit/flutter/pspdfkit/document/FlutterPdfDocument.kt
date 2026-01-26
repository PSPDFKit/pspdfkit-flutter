/*
 * Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit.document

import com.pspdfkit.document.PdfDocument
import com.pspdfkit.document.formatters.DocumentJsonFormatter
import com.pspdfkit.document.formatters.XfdfFormatter
import com.pspdfkit.document.processor.PdfProcessor
import com.pspdfkit.document.processor.PdfProcessorTask
import com.pspdfkit.flutter.pspdfkit.AnnotationTypeAdapter
import com.pspdfkit.flutter.pspdfkit.api.AnnotationProcessingMode
import com.pspdfkit.flutter.pspdfkit.api.AnnotationType
import com.pspdfkit.flutter.pspdfkit.api.DocumentSaveOptions
import com.pspdfkit.flutter.pspdfkit.api.NutrientApiError
import com.pspdfkit.flutter.pspdfkit.api.PageInfo
import com.pspdfkit.flutter.pspdfkit.api.PdfDocumentApi
import com.pspdfkit.flutter.pspdfkit.api.PdfVersion
import com.pspdfkit.flutter.pspdfkit.forms.FormHelper
import com.pspdfkit.flutter.pspdfkit.util.DocumentJsonDataProvider
import com.pspdfkit.flutter.pspdfkit.util.Preconditions.requireNotNullNotEmpty
import com.pspdfkit.flutter.pspdfkit.util.ProcessorHelper
import com.pspdfkit.flutter.pspdfkit.util.areValidIndexes
import com.pspdfkit.forms.ChoiceFormElement
import com.pspdfkit.forms.EditableButtonFormElement
import com.pspdfkit.forms.SignatureFormElement
import com.pspdfkit.forms.TextFormElement
import io.flutter.plugin.common.BinaryMessenger
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.schedulers.Schedulers
import io.reactivex.rxjava3.subscribers.DisposableSubscriber
import kotlinx.serialization.json.Json
import org.json.JSONArray
import org.json.JSONObject
import android.util.Base64
import com.pspdfkit.flutter.pspdfkit.util.BinaryDataProvider
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.nio.charset.StandardCharsets
import java.util.EnumSet

class FlutterPdfDocument(
    val pdfDocument: PdfDocument,
    val documentId: String? = null,
    private val binaryMessenger: BinaryMessenger? = null
) : PdfDocumentApi {

    companion object {
        // Registry to track document instances by their IDs
        val documentInstances = mutableMapOf<String, FlutterPdfDocument>()

        fun registerDocument(documentId: String, document: FlutterPdfDocument) {
            documentInstances[documentId] = document
        }

        fun unregisterDocument(documentId: String) {
            documentInstances.remove(documentId)
        }
    }

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
        val label = pdfDocument.getPageLabel(pageIndex.toInt(), true)
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

    override fun getFormFieldJson(fieldName: String, callback: (Result<String>) -> Unit) {
        try {
            val formField = pdfDocument.formProvider.getFormFieldWithFullyQualifiedName(fieldName)
            if (formField == null) {
                callback(Result.failure(Exception("Form field not found")))
                return
            }
            val formFieldData = FormHelper.formFieldPropertiesToMap(listOf(formField))
            val jsonObject = JSONObject(formFieldData.first())
            callback(Result.success(jsonObject.toString()))
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }

    override fun getFormFieldsJson(callback: (Result<String>) -> Unit) {
        try {
            val formFields = pdfDocument.formProvider.formFields
            val formFieldData = FormHelper.formFieldPropertiesToMap(formFields)
            val jsonArray = JSONArray()
            for (field in formFieldData) {
                jsonArray.put(JSONObject(field))
            }
            callback(Result.success(jsonArray.toString()))
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
                                        NutrientApiError(
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
                                    NutrientApiError(
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
                                NutrientApiError(
                                    "Signature form elements cannot be set programmatically",
                                    "Signature form elements are not supported.",
                                )
                            )
                        )
                    } else {
                        callback(
                            Result.failure(
                                NutrientApiError(
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
                            NutrientApiError(
                                "Error while searching for a form element with name $fullyQualifiedName",
                                throwable.message ?: "",
                            )
                        )
                    )
                }
            ) // Form element for the given name not found.
            { callback(Result.failure(NutrientApiError("Form element not found", ""))) }
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
                                    NutrientApiError(
                                        "Signature form elements cannot be read programmatically",
                                        "Signature form elements are not supported.",
                                    )
                                )
                            )
                        }

                        else -> {
                            callback(
                                Result.failure(
                                    NutrientApiError(
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
                            NutrientApiError(
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
                        NutrientApiError(
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
                        NutrientApiError(
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
                        NutrientApiError(
                            "Failed to export Instant JSON",
                            throwable.message ?: "",
                        )
                    )
                )
            }
    }

    override fun addAnnotation(
        jsonAnnotation: String,
        attachment: Any?,
        callback: (Result<Boolean?>) -> Unit
    ) {
        // WORKAROUND for PSPDFKit Native SDK limitation:
        //
        // Problem: When creating image annotations, PSPDFKit fires `onAnnotationCreated`
        // synchronously during `createAnnotationFromInstantJsonAsync()`, BEFORE we can attach
        // the binary image data. When event listeners call `toInstantJson()` on the annotation,
        // it fails with: "Can't create Instant JSON for stamp annotation that has no content -
        // title, stamp icon or an image!"
        //
        // Root cause: PSPDFKit stores image annotations as StampAnnotations internally.
        // The `toInstantJson()` method validates that stamps have "content" (title, stampType,
        // or attached image). Since the image isn't attached yet when the event fires, and
        // image annotations don't have title/stampType by spec, validation fails.
        //
        // Workaround: Inject a temporary title into the JSON before creating the annotation.
        // This satisfies the validation check. Once the image is attached (after creation),
        // subsequent serialization includes the image data.
        //
        // Note: The Instant JSON spec does NOT define `title` for image annotations
        // (only for stamps). This is purely an internal workaround for PSPDFKit's validation.
        //
        // Ideal fix: PSPDFKit should either:
        // 1. Allow attaching binary data before/during annotation creation, or
        // 2. Skip validation in `toInstantJson()` for annotations being created, or
        // 3. Delay firing `onAnnotationCreated` until after attachments are set
        val processedJson = if (attachment != null && attachment is String) {
            try {
                val json = JSONObject(jsonAnnotation)
                val annotationType = json.optString("type", "")
                // Inject placeholder title for image/stamp annotations with binary attachments.
                // "Image" for pspdfkit/image, "Stamp" for pspdfkit/stamp (per spec naming).
                when (annotationType) {
                    "pspdfkit/image" -> {
                        if (!json.has("title") || json.optString("title").isNullOrEmpty()) {
                            json.put("title", "Image")
                        }
                    }
                    "pspdfkit/stamp" -> {
                        if (!json.has("title") || json.optString("title").isNullOrEmpty()) {
                            json.put("title", "Stamp")
                        }
                    }
                }
                json.toString()
            } catch (e: Exception) {
                jsonAnnotation // Use original if parsing fails
            }
        } else {
            jsonAnnotation
        }

        disposable =
            pdfDocument.annotationProvider.createAnnotationFromInstantJsonAsync(processedJson)
                .subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                    { annotation ->
                        // For stamp/image annotations, set title IMMEDIATELY after creation.
                        // This is needed because PSPDFKit fires onAnnotationCreated synchronously
                        // during createAnnotationFromInstantJsonAsync(), and the title from JSON
                        // may not be applied for image annotations (title is not in the image spec).
                        if (annotation is com.pspdfkit.annotations.StampAnnotation) {
                            if (annotation.title.isNullOrEmpty()) {
                                val type = try {
                                    JSONObject(processedJson).optString("type", "")
                                } catch (e: Exception) { "" }
                                annotation.title = if (type == "pspdfkit/image") "Image" else "Stamp"
                            }
                        }

                        // Handle attachment if provided
                        if (attachment != null && attachment is String) {
                            try {
                                val attachmentJson = JSONObject(attachment)
                                val binary = attachmentJson.optString("binary")
                                val contentType = attachmentJson.optString("contentType", "application/octet-stream")

                                if (binary.isNotEmpty()) {
                                    val binaryData = Base64.decode(binary, Base64.DEFAULT)
                                    val dataProvider = BinaryDataProvider(binaryData)
                                    annotation.attachBinaryInstantJsonAttachment(dataProvider, contentType)

                                    // Generate the appearance stream to render the attached image.
                                    annotation.generateAppearanceStreamAsync()
                                        .subscribeOn(Schedulers.computation())
                                        .observeOn(AndroidSchedulers.mainThread())
                                        .subscribe(
                                            {
                                                callback(Result.success(true))
                                            },
                                            { appearanceError ->
                                                // Log but don't fail - the annotation was created successfully,
                                                // just the appearance generation failed
                                                android.util.Log.w("FlutterPdfDocument", "Failed to generate appearance stream: ${appearanceError.message}")
                                                callback(Result.success(true))
                                            }
                                        )
                                    return@subscribe
                                }
                            } catch (e: Exception) {
                                // Log but don't fail - annotation was created successfully
                                android.util.Log.w("FlutterPdfDocument", "Failed to attach binary: ${e.message}")
                            }
                        }
                        callback(Result.success(true))
                    }
                ) { throwable ->
                    callback(
                        Result.failure(
                            NutrientApiError(
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
            val annotationObject = JSONObject(jsonAnnotation)
            // Get name or Instant JSON ID
            val name = annotationObject.optString("name", null)
            val instantId = annotationObject.optString("id", null)

            if (name.isNullOrEmpty() && instantId.isNullOrEmpty()) {
                callback(Result.failure(Exception("Annotation has no identifier (name or id)")))
                return
            }

            val pageIndex = annotationObject.getInt("pageIndex")
            val allAnnotations = pdfDocument.annotationProvider.getAnnotations(pageIndex)

            // Try to find the annotation using multiple strategies:
            // 1. First try by name (most reliable for user-created annotations)
            // 2. Then try by uuid property
            // 3. Finally try by matching the Instant JSON id
            var annotation: com.pspdfkit.annotations.Annotation? = null

            if (!name.isNullOrEmpty()) {
                annotation = allAnnotations.firstOrNull { it.name == name }
            }

            if (annotation == null && !instantId.isNullOrEmpty()) {
                // Try matching by uuid property
                annotation = allAnnotations.firstOrNull { it.uuid == instantId }

                // If still not found, try matching by the id in the annotation's Instant JSON
                if (annotation == null) {
                    annotation = allAnnotations.firstOrNull { ann ->
                        try {
                            val annJson = ann.toInstantJson()
                            if (!annJson.isNullOrEmpty()) {
                                val annJsonObj = JSONObject(annJson)
                                val annId = annJsonObj.optString("id", null)
                                annId == instantId
                            } else {
                                false
                            }
                        } catch (e: Exception) {
                            false
                        }
                    }
                }
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

    override fun getAnnotationsJson(pageIndex: Long, type: String, callback: (Result<String>) -> Unit) {
        try {
            val jsonArray = JSONArray()

            // Get annotations directly from the annotation provider
            val annotations = pdfDocument.annotationProvider.getAnnotations(pageIndex.toInt())
            val annotationTypeSet = AnnotationTypeAdapter.fromString(type)
            val filterAll = annotationTypeSet.size == com.pspdfkit.annotations.AnnotationType.values().size

            for (annotation in annotations) {
                // Filter by type if not "all"
                if (!filterAll && !annotationTypeSet.contains(annotation.type)) {
                    continue
                }

                // Skip floating/unattached annotations that can't be serialized to JSON.
                // These are typically internal annotations (like some LINK annotations) that
                // haven't been fully connected to the document structure.
                if (!annotation.isAttached) {
                    continue
                }

                // For stamp/image annotations that don't have content yet,
                // set a placeholder title so toInstantJson() can succeed.
                // Don't check hasBinaryInstantJsonAttachment() because it may return true
                // before actual data is attached (it checks imageAttachmentId, not binary data).
                if (annotation is com.pspdfkit.annotations.StampAnnotation) {
                    if (annotation.title.isNullOrEmpty() && annotation.stampType == null) {
                        annotation.title = "Image"
                    }
                }

                // Try to convert annotation to JSON, skip if it fails
                // Some annotations (like stamp/image annotations) may throw IllegalStateException
                // if they don't have their content fully set yet
                var jsonString: String
                try {
                    jsonString = annotation.toInstantJson() ?: continue
                } catch (e: IllegalStateException) {
                    // Skip annotations that can't be serialized
                    continue
                }

                // Skip annotations that can't be serialized to JSON
                if (jsonString.isEmpty()) {
                    continue
                }

                // For annotations with binary attachments, include the attachment data
                if (annotation.hasBinaryInstantJsonAttachment()) {
                    jsonString = addAttachmentToJson(annotation, jsonString)
                }

                // Try to parse the JSON, skip if it fails
                try {
                    jsonArray.put(JSONObject(jsonString))
                } catch (e: Exception) {
                    android.util.Log.w("FlutterPdfDocument", "Failed to parse annotation JSON: ${e.message}")
                    continue
                }
            }

            callback(Result.success(jsonArray.toString()))
        } catch (e: Exception) {
            android.util.Log.e("FlutterPdfDocument", "Error getting annotations JSON: ${e.message}", e)
            callback(Result.failure(e))
        }
    }

    /**
     * Adds binary attachment data to an annotation JSON string.
     * This enables copying annotations with attachments (images, stamps, files) between documents.
     */
    private fun addAttachmentToJson(annotation: com.pspdfkit.annotations.Annotation, jsonString: String): String {
        return try {
            val jsonObject = JSONObject(jsonString)
            addAttachmentToJsonObject(annotation, jsonObject)
            jsonObject.toString()
        } catch (e: Exception) {
            android.util.Log.w("FlutterPdfDocument", "Failed to add attachment to JSON: ${e.message}")
            jsonString
        }
    }

    /**
     * Adds binary attachment data to a JSONObject.
     */
    private fun addAttachmentToJsonObject(annotation: com.pspdfkit.annotations.Annotation, jsonObject: JSONObject) {
        try {
            val outputStream = ByteArrayOutputStream()
            val contentType = annotation.fetchBinaryInstantJsonAttachment(outputStream)

            if (contentType != null && outputStream.size() > 0) {
                val binaryData = outputStream.toByteArray()
                val base64Data = Base64.encodeToString(binaryData, Base64.NO_WRAP)

                // Get the attachment ID from the annotation JSON
                val attachmentId = jsonObject.optString("imageAttachmentId", null)
                    ?: jsonObject.optString("stampAttachmentId", null)
                    ?: jsonObject.optString("fileAttachmentId", null)
                    ?: "attachment-${annotation.uuid ?: annotation.name ?: System.currentTimeMillis()}"

                val attachmentObject = JSONObject()
                attachmentObject.put("id", attachmentId)
                attachmentObject.put("binary", base64Data)
                attachmentObject.put("contentType", contentType)

                jsonObject.put("attachment", attachmentObject)
            }
        } catch (e: Exception) {
            android.util.Log.w("FlutterPdfDocument", "Failed to fetch attachment binary: ${e.message}")
        }
    }

    override fun getAllUnsavedAnnotationsJson(callback: (Result<String>) -> Unit) {
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
                        NutrientApiError(
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
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { annotations ->
                    // Annotations parsed from XFDF aren't added to the document automatically.
                    // You need to add them manually.
                    for (annotation in annotations) {
                        pdfDocument.annotationProvider.addAnnotationToPage(annotation)
                    }
                    callback(Result.success(true))
                },
                { throwable ->
                    callback(
                        Result.failure(
                            NutrientApiError(
                                "Error while importing XFDF",
                                throwable.message ?: "",
                            )
                        )
                    )
                }
            )
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
                            NutrientApiError(
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

        if (outputPath != null) {
            // When saving to a new path, use PdfProcessor to ensure all annotations
            // (including those from Instant JSON) are properly written to the new file
            try {
                val task = PdfProcessorTask.fromDocument(pdfDocument)

                disposable = PdfProcessor.processDocumentAsync(task, File(outputPath))
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribeWith(object : DisposableSubscriber<PdfProcessor.ProcessorProgress?>() {
                        override fun onComplete() {
                            callback(Result.success(true))
                        }

                        override fun onNext(progress: PdfProcessor.ProcessorProgress?) {
                            // Progress updates
                        }

                        override fun onError(throwable: Throwable) {
                            callback(
                                Result.failure(
                                    NutrientApiError(
                                        "Error while saving document",
                                        throwable.message ?: "",
                                    )
                                )
                            )
                        }
                    })
            } catch (e: Exception) {
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error while saving document",
                            e.message ?: "",
                        )
                    )
                )
            }
        } else {
            // Save in place
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
                            NutrientApiError(
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

    override fun processAnnotations(
        type: AnnotationType,
        processingMode: AnnotationProcessingMode,
        destinationPath: String,
        callback: (Result<Boolean>) -> Unit
    ) {
        try {
            // Convert Flutter annotation type to native annotation type
            val annotationType = when (type) {
                AnnotationType.ALL -> com.pspdfkit.annotations.AnnotationType.NONE // Will use changeAllAnnotations
                AnnotationType.NONE -> com.pspdfkit.annotations.AnnotationType.NONE
                AnnotationType.UNDEFINED -> com.pspdfkit.annotations.AnnotationType.NONE
                AnnotationType.LINK -> com.pspdfkit.annotations.AnnotationType.LINK
                AnnotationType.HIGHLIGHT -> com.pspdfkit.annotations.AnnotationType.HIGHLIGHT
                AnnotationType.STRIKEOUT -> com.pspdfkit.annotations.AnnotationType.STRIKEOUT
                AnnotationType.UNDERLINE -> com.pspdfkit.annotations.AnnotationType.UNDERLINE
                AnnotationType.SQUIGGLY -> com.pspdfkit.annotations.AnnotationType.SQUIGGLY
                AnnotationType.FREE_TEXT -> com.pspdfkit.annotations.AnnotationType.FREETEXT
                AnnotationType.INK -> com.pspdfkit.annotations.AnnotationType.INK
                AnnotationType.SQUARE -> com.pspdfkit.annotations.AnnotationType.SQUARE
                AnnotationType.CIRCLE -> com.pspdfkit.annotations.AnnotationType.CIRCLE
                AnnotationType.LINE -> com.pspdfkit.annotations.AnnotationType.LINE
                AnnotationType.NOTE -> com.pspdfkit.annotations.AnnotationType.NOTE
                AnnotationType.STAMP -> com.pspdfkit.annotations.AnnotationType.STAMP
                AnnotationType.CARET -> com.pspdfkit.annotations.AnnotationType.CARET
                AnnotationType.MEDIA -> com.pspdfkit.annotations.AnnotationType.RICHMEDIA
                AnnotationType.SCREEN -> com.pspdfkit.annotations.AnnotationType.SCREEN
                AnnotationType.WIDGET -> com.pspdfkit.annotations.AnnotationType.WIDGET
                AnnotationType.FILE -> com.pspdfkit.annotations.AnnotationType.FILE
                AnnotationType.SOUND -> com.pspdfkit.annotations.AnnotationType.SOUND
                AnnotationType.POLYGON -> com.pspdfkit.annotations.AnnotationType.POLYGON
                AnnotationType.POLYLINE -> com.pspdfkit.annotations.AnnotationType.POLYLINE
                AnnotationType.POPUP -> com.pspdfkit.annotations.AnnotationType.POPUP
                AnnotationType.WATERMARK -> com.pspdfkit.annotations.AnnotationType.WATERMARK
                AnnotationType.TRAP_NET -> com.pspdfkit.annotations.AnnotationType.TRAPNET
                AnnotationType.TYPE3D -> com.pspdfkit.annotations.AnnotationType.TYPE3D
                AnnotationType.REDACT -> com.pspdfkit.annotations.AnnotationType.REDACT
                AnnotationType.IMAGE -> com.pspdfkit.annotations.AnnotationType.STAMP
            }

            // Convert processing mode
            val annotationProcessingMode = ProcessorHelper.processModeFromString(processingMode.name.lowercase())

            // Create processor task
            val task = if (type == AnnotationType.ALL || type == AnnotationType.NONE) {
                PdfProcessorTask.fromDocument(pdfDocument).changeAllAnnotations(annotationProcessingMode)
            } else {
                PdfProcessorTask.fromDocument(pdfDocument)
                    .changeAnnotationsOfType(annotationType, annotationProcessingMode)
            }

            // Process document asynchronously
            disposable = PdfProcessor.processDocumentAsync(task, File(destinationPath))
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeWith(object : DisposableSubscriber<PdfProcessor.ProcessorProgress?>() {
                    override fun onComplete() {
                        callback(Result.success(true))
                    }

                    override fun onNext(progress: PdfProcessor.ProcessorProgress?) {
                        // Progress updates - could be exposed to Flutter in the future
                    }

                    override fun onError(throwable: Throwable) {
                        callback(
                            Result.failure(
                                NutrientApiError(
                                    "AnnotationProcessingError",
                                    "Failed to process annotations: ${throwable.message}",
                                    throwable.stackTraceToString()
                                )
                            )
                        )
                    }
                })
        } catch (e: Exception) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "AnnotationProcessingError",
                        "Failed to process annotations: ${e.message}",
                        e.stackTraceToString()
                    )
                )
            )
        }
    }

    override fun closeDocument(callback: (Result<Boolean>) -> Unit) {
        try {
            // Dispose of any pending operations
            dispose()

            // Clean up for headless documents: unregister from registry and message channels
            if (documentId != null) {
                // Unregister from document registry
                unregisterDocument(documentId)

                // Clean up the PdfDocumentApi message channel
                if (binaryMessenger != null) {
                    PdfDocumentApi.setUp(binaryMessenger, null, documentId)
                }
            }

            callback(Result.success(true))
        } catch (e: Exception) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "DocumentCloseError",
                        "Failed to close document: ${e.message}",
                        e.stackTraceToString()
                    )
                )
            )
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

    // ==========================================
    // iOS Dirty State APIs (Not supported on Android)
    // ==========================================

    override fun iOSHasDirtyAnnotations(callback: (Result<Boolean>) -> Unit) {
        callback(
            Result.failure(
                NutrientApiError(
                    "PlatformNotSupported",
                    "iOSHasDirtyAnnotations is only available on iOS. Use androidHasUnsavedAnnotationChanges() on Android."
                )
            )
        )
    }

    override fun iOSGetAnnotationIsDirty(
        pageIndex: Long,
        annotationId: String,
        callback: (Result<Boolean>) -> Unit
    ) {
        callback(
            Result.failure(
                NutrientApiError(
                    "PlatformNotSupported",
                    "iOSGetAnnotationIsDirty is only available on iOS. Android does not support per-annotation dirty state."
                )
            )
        )
    }

    override fun iOSSetAnnotationIsDirty(
        pageIndex: Long,
        annotationId: String,
        isDirty: Boolean,
        callback: (Result<Boolean>) -> Unit
    ) {
        callback(
            Result.failure(
                NutrientApiError(
                    "PlatformNotSupported",
                    "iOSSetAnnotationIsDirty is only available on iOS. Android does not support per-annotation dirty state."
                )
            )
        )
    }

    override fun iOSClearNeedsSaveFlag(callback: (Result<Boolean>) -> Unit) {
        callback(
            Result.failure(
                NutrientApiError(
                    "PlatformNotSupported",
                    "iOSClearNeedsSaveFlag is only available on iOS. Android does not support clearing the needs-save flag."
                )
            )
        )
    }

    // ==========================================
    // Android Dirty State APIs
    // ==========================================

    override fun androidHasUnsavedAnnotationChanges(callback: (Result<Boolean>) -> Unit) {
        try {
            val hasUnsavedChanges = pdfDocument.annotationProvider.hasUnsavedChanges()
            callback(Result.success(hasUnsavedChanges))
        } catch (e: Exception) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "AndroidDirtyStateError",
                        "Failed to check annotation unsaved changes: ${e.message}"
                    )
                )
            )
        }
    }

    override fun androidHasUnsavedFormChanges(callback: (Result<Boolean>) -> Unit) {
        try {
            val hasUnsavedChanges = pdfDocument.formProvider.hasUnsavedChanges()
            callback(Result.success(hasUnsavedChanges))
        } catch (e: Exception) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "AndroidDirtyStateError",
                        "Failed to check form unsaved changes: ${e.message}"
                    )
                )
            )
        }
    }

    override fun androidHasUnsavedBookmarkChanges(callback: (Result<Boolean>) -> Unit) {
        try {
            val hasUnsavedChanges = pdfDocument.bookmarkProvider.hasUnsavedChanges()
            callback(Result.success(hasUnsavedChanges))
        } catch (e: Exception) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "AndroidDirtyStateError",
                        "Failed to check bookmark unsaved changes: ${e.message}"
                    )
                )
            )
        }
    }

    override fun androidGetBookmarkIsDirty(bookmarkId: String, callback: (Result<Boolean>) -> Unit) {
        try {
            val bookmarks = pdfDocument.bookmarkProvider.bookmarks
            val bookmark = bookmarks.find { it.name == bookmarkId }

            if (bookmark == null) {
                callback(
                    Result.failure(
                        NutrientApiError(
                            "BookmarkNotFound",
                            "Bookmark with name '$bookmarkId' not found. Bookmarks are identified by their name property."
                        )
                    )
                )
                return
            }

            callback(Result.success(bookmark.isDirty))
        } catch (e: Exception) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "AndroidDirtyStateError",
                        "Failed to get bookmark dirty state: ${e.message}"
                    )
                )
            )
        }
    }

    override fun androidClearBookmarkDirtyState(bookmarkId: String, callback: (Result<Boolean>) -> Unit) {
        try {
            val bookmarks = pdfDocument.bookmarkProvider.bookmarks
            val bookmark = bookmarks.find { it.name == bookmarkId }

            if (bookmark == null) {
                callback(
                    Result.failure(
                        NutrientApiError(
                            "BookmarkNotFound",
                            "Bookmark with name '$bookmarkId' not found. Bookmarks are identified by their name property."
                        )
                    )
                )
                return
            }

            bookmark.clearDirty()
            callback(Result.success(true))
        } catch (e: Exception) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "AndroidDirtyStateError",
                        "Failed to clear bookmark dirty state: ${e.message}"
                    )
                )
            )
        }
    }

    override fun androidGetFormFieldIsDirty(
        fullyQualifiedName: String,
        callback: (Result<Boolean>) -> Unit
    ) {
        try {
            val formField = pdfDocument.formProvider.getFormFieldWithFullyQualifiedName(fullyQualifiedName)

            if (formField == null) {
                callback(
                    Result.failure(
                        NutrientApiError(
                            "FormFieldNotFound",
                            "Form field with name '$fullyQualifiedName' not found."
                        )
                    )
                )
                return
            }

            callback(Result.success(formField.isDirty))
        } catch (e: Exception) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "AndroidDirtyStateError",
                        "Failed to get form field dirty state: ${e.message}"
                    )
                )
            )
        }
    }

    // ==========================================
    // Web Dirty State APIs (Not supported on Android)
    // ==========================================

    override fun webHasUnsavedChanges(callback: (Result<Boolean>) -> Unit) {
        callback(
            Result.failure(
                NutrientApiError(
                    "PlatformNotSupported",
                    "webHasUnsavedChanges is only available on Web. Use androidHasUnsavedAnnotationChanges(), androidHasUnsavedFormChanges(), or androidHasUnsavedBookmarkChanges() on Android."
                )
            )
        )
    }
}