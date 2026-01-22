/*
 * Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */
package com.pspdfkit.flutter.pspdfkit

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import com.pspdfkit.Nutrient
import com.pspdfkit.PSPDFKit
import com.pspdfkit.PSPDFKit.VERSION
import com.pspdfkit.document.formatters.DocumentJsonFormatter
import com.pspdfkit.document.formatters.XfdfFormatter
import com.pspdfkit.document.html.HtmlToPdfConverter
import com.pspdfkit.document.processor.PdfProcessor
import com.pspdfkit.document.processor.PdfProcessor.ProcessorProgress
import com.pspdfkit.document.processor.PdfProcessorTask
import com.pspdfkit.exceptions.NutrientException
import com.pspdfkit.flutter.pspdfkit.AnnotationConfigurationAdaptor.Companion.convertAnnotationConfigurations
import com.pspdfkit.flutter.pspdfkit.annotations.FlutterAnnotationPresetConfiguration
import com.pspdfkit.flutter.pspdfkit.api.AnnotationMenuConfigurationData
import com.pspdfkit.flutter.pspdfkit.api.AndroidPermissionStatus
import com.pspdfkit.flutter.pspdfkit.api.AnnotationProcessingMode
import com.pspdfkit.flutter.pspdfkit.api.NutrientApi
import com.pspdfkit.flutter.pspdfkit.api.NutrientApiError
import com.pspdfkit.flutter.pspdfkit.events.FlutterAnalyticsClient
import com.pspdfkit.flutter.pspdfkit.pdfgeneration.PdfPageAdaptor
import com.pspdfkit.flutter.pspdfkit.util.DocumentJsonDataProvider
import com.pspdfkit.flutter.pspdfkit.util.Preconditions
import com.pspdfkit.flutter.pspdfkit.util.ProcessorHelper.annotationTypeFromString
import com.pspdfkit.flutter.pspdfkit.util.ProcessorHelper.processModeFromString
import com.pspdfkit.flutter.pspdfkit.util.addFileSchemeIfMissing
import com.pspdfkit.flutter.pspdfkit.util.areValidIndexes
import com.pspdfkit.flutter.pspdfkit.util.isImageDocument
import com.pspdfkit.forms.ChoiceFormElement
import com.pspdfkit.forms.EditableButtonFormElement
import com.pspdfkit.forms.FormElement
import com.pspdfkit.forms.SignatureFormElement
import com.pspdfkit.forms.TextFormElement
import com.pspdfkit.initialization.CrossPlatformTechnology
import com.pspdfkit.initialization.InitializationOptions
import com.pspdfkit.instant.client.InstantProgress
import com.pspdfkit.instant.document.InstantPdfDocument
import com.pspdfkit.instant.ui.InstantPdfActivityIntentBuilder
import com.pspdfkit.preferences.PSPDFKitPreferences
import com.pspdfkit.ui.PdfActivity
import com.pspdfkit.ui.PdfActivityIntentBuilder
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.schedulers.Schedulers
import io.reactivex.rxjava3.subscribers.DisposableSubscriber
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonObject
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.nio.charset.StandardCharsets
import androidx.core.net.toUri

class PspdfkitApiImpl(private var activityPluginBinding: ActivityPluginBinding?) : NutrientApi {

    private var disposable: Disposable? = null
    private var analyticsEventClient: FlutterAnalyticsClient? = null

    fun dispose() {
        disposable?.dispose()
        analyticsEventClient = null
    }

    fun setActivityPluginBinding(activityPluginBinding: ActivityPluginBinding?) {
        this.activityPluginBinding = activityPluginBinding
    }

    fun setAnalyticsEventClient(analyticsEventClient: FlutterAnalyticsClient?) {
        this.analyticsEventClient = analyticsEventClient
    }

    override fun getFrameworkVersion(callback: (Result<String?>) -> Unit) {
        callback(Result.success(VERSION))
    }

    override fun setLicenseKey(licenseKey: String?, callback: (Result<Unit>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        setLicenseKey(activityPluginBinding?.activity as FragmentActivity, licenseKey)
        callback(Result.success(Unit))
    }

    override fun setLicenseKeys(
        androidLicenseKey: String?,
        iOSLicenseKey: String?,
        webLicenseKey: String?,
        callback: (Result<Unit>) -> Unit
    ) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        setLicenseKey(activityPluginBinding?.activity as FragmentActivity, androidLicenseKey)
        callback(Result.success(Unit))
    }

    override fun present(
        document: String, configuration: Map<String, Any>?, callback: (Result<Boolean?>) -> Unit
    ) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        try {
            var documentPath = document
            documentPath = addFileSchemeIfMissing(documentPath)
            val configurationMap = configuration as HashMap<String, Any>?
            val configurationAdapter = ConfigurationAdapter(
                activityPluginBinding?.activity as FragmentActivity, configurationMap
            )
            val imageDocument = isImageDocument(documentPath)
            val intent = if (imageDocument) {
                PdfActivityIntentBuilder.fromImageUri(
                    activityPluginBinding?.activity as FragmentActivity, Uri.parse(documentPath)
                ).activityClass(FlutterPdfActivity::class.java)
                    .configuration(configurationAdapter.build()).build()
            } else {
                PdfActivityIntentBuilder.fromUri(
                    activityPluginBinding?.activity as FragmentActivity, Uri.parse(documentPath)
                ).activityClass(FlutterPdfActivity::class.java)
                    .configuration(configurationAdapter.build())
                    .passwords(configurationAdapter.password).build()
            }
            activityPluginBinding?.activity?.startActivity(intent)
            callback(Result.success(activityPluginBinding?.activity != null))
        } catch (e: NutrientException) {
            callback(Result.failure(NutrientApiError("Error", e.message)))
        }
    }

    override fun presentInstant(
        serverUrl: String,
        jwt: String,
        configuration: Map<String, Any>?,
        callback: (Result<Boolean?>) -> Unit
    ) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        try {
            val configurationMapInstant = configuration as HashMap<String, Any>
            val configurationAdapterInstant = ConfigurationAdapter(
                activityPluginBinding?.activity as FragmentActivity, configurationMapInstant
            )
            val intentInstant = InstantPdfActivityIntentBuilder.fromInstantDocument(
                activityPluginBinding?.activity as FragmentActivity, serverUrl, jwt
            ).activityClass(FlutterInstantPdfActivity::class.java)
                .configuration(configurationAdapterInstant.build()).build()
            activityPluginBinding?.activity?.startActivity(intentInstant)
            callback(Result.success(activityPluginBinding?.activity != null))
        } catch (e: NutrientException) {
            callback(Result.failure(NutrientApiError("Error", e.message)))
        }
    }

    override fun setFormFieldValue(
        value: String, fullyQualifiedName: String, callback: (Result<Boolean?>) -> Unit
    ) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val document = Preconditions.requireDocumentNotNull(
            activityPluginBinding?.activity as PdfActivity, "Pspdfkit.setFormFieldValue(String)"
        )
        disposable = document.formProvider.getFormElementWithNameAsync(fullyQualifiedName)
            .subscribeOn(Schedulers.computation()).observeOn(AndroidSchedulers.mainThread())
            .subscribe({ formElement: FormElement? ->
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
                            callback(Result.success(false))
                        }
                    }
                } else if (formElement is ChoiceFormElement) {
                    val selectedIndexes: MutableList<Int> = ArrayList()
                    if (areValidIndexes(value, selectedIndexes)) {
                        formElement.selectedIndexes = selectedIndexes
                        callback(Result.success(true))
                    } else {
                        callback(
                            Result.failure(
                                NutrientApiError(
                                    "InvalidArgument",
                                    "\"value\" argument needs a list of " + "integers to set selected indexes for a choice " + "form element (e.g.: \"1, 3, 5\")."
                                )
                            )
                        )
                    }
                } else if (formElement is SignatureFormElement) {
                    callback(
                        Result.failure(
                            NutrientApiError(
                                "UnsupportedOperation",
                                "Signature form elements are not supported."
                            )
                        )
                    )
                } else {
                    callback(Result.success(false))
                }
            }, { throwable: Throwable ->
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error", String.format(
                                "Error while searching for a form element with name %s",
                                fullyQualifiedName
                            ), throwable.message
                        )
                    )
                )
            },  // Form element for the given name not found.
                { callback(Result.success(false)) })

    }

    override fun getFormFieldValue(
        fullyQualifiedName: String, callback: (Result<String?>) -> Unit
    ) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val document = Preconditions.requireDocumentNotNull(
            activityPluginBinding?.activity as PdfActivity, "Pspdfkit.getFormFieldValue()"
        )
        disposable = document.formProvider.getFormElementWithNameAsync(fullyQualifiedName)
            .subscribeOn(Schedulers.computation()).observeOn(AndroidSchedulers.mainThread())
            .subscribe({ formElement: FormElement? ->
                when (formElement) {
                    is TextFormElement -> {
                        val text = formElement.text
                        callback(Result.success(text))
                    }

                    is EditableButtonFormElement -> {
                        val isSelected = formElement.isSelected
                        callback(Result.success(if (isSelected) "selected" else "deselected"))
                    }

                    is ChoiceFormElement -> {
                        val selectedIndexes = formElement.selectedIndexes
                        val stringBuilder = StringBuilder()
                        val iterator: Iterator<Int> = selectedIndexes.iterator()
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
                                    "UnsupportedOperation",
                                    "Signature form elements are not supported."
                                )
                            )
                        )
                    }

                    else -> {
                        callback(Result.success(null))
                    }
                }
            }, { throwable: Throwable ->
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error", String.format(
                                "Error while searching for a form element with name %s",
                                fullyQualifiedName
                            ), throwable.message
                        )
                    )
                )
            },  // Form element for the given name not found.
                {
                    callback(
                        Result.failure(
                            NutrientApiError(
                                "Error", String.format(
                                    "Form element not found with name %s", fullyQualifiedName
                                )
                            )
                        )
                    )
                })
    }

    override fun applyInstantJson(annotationsJson: String, callback: (Result<Boolean?>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val document = Preconditions.requireDocumentNotNull(
            activityPluginBinding?.activity as PdfActivity, "Pspdfkit.applyInstantJson(String)"
        )
        val documentJsonDataProvider = DocumentJsonDataProvider(annotationsJson)
        disposable =
            DocumentJsonFormatter.importDocumentJsonAsync(document, documentJsonDataProvider)
                .subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread())
                .subscribe({ callback(Result.success(true)) }, { throwable: Throwable ->
                    callback(
                        Result.failure(
                            NutrientApiError(
                                "Error",
                                "Error while importing document Instant JSON",
                                throwable.message
                            )
                        )
                    )
                })
    }

    override fun exportInstantJson(callback: (Result<String?>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val document = Preconditions.requireDocumentNotNull(
            activityPluginBinding?.activity as PdfActivity, "Pspdfkit.exportInstantJson()"
        )
        val outputStream = ByteArrayOutputStream()

        disposable = DocumentJsonFormatter.exportDocumentJsonAsync(document, outputStream)
            .subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread()).subscribe({
                callback(Result.success(outputStream.toString(StandardCharsets.UTF_8.name())))
            }, { throwable: Throwable ->
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error",
                            "Error while exporting document Instant JSON",
                            throwable.message
                        )
                    )
                )
            })
    }

    override fun addAnnotation(annotation: String, attachment:String?, callback: (Result<Boolean?>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val document = Preconditions.requireDocumentNotNull(
            activityPluginBinding?.activity as PdfActivity, "Pspdfkit.exportInstantJson()"
        )

        disposable =
            document.annotationProvider.createAnnotationFromInstantJsonAsync(annotation)
                .subscribeOn(Schedulers.computation()).observeOn(AndroidSchedulers.mainThread())
                .subscribe({ result ->
                    document.annotationProvider.addAnnotationToPage(result)
                    callback(Result.success(true))
                }) { throwable ->
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

    override fun removeAnnotation(annotation: String, callback: (Result<Boolean?>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val document = Preconditions.requireDocumentNotNull(
            activityPluginBinding?.activity as PdfActivity, "Pspdfkit.exportInstantJson()"
        )
        //Annotation from JSON.
        val annotationObject = document.annotationProvider.createAnnotationFromInstantJson(annotation)
        document.annotationProvider.removeAnnotationFromPage(annotationObject)
        callback(Result.success(true))
    }

    override fun getAnnotationsJson(
        pageIndex: Long,
        type: String,
        callback: (Result<String?>) -> Unit
    ) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val document = Preconditions.requireDocumentNotNull(
            activityPluginBinding?.activity as PdfActivity, "Pspdfkit.getAnnotationsJson()"
        )

        val jsonArray = org.json.JSONArray()
        // noinspection checkResult
        document.annotationProvider.getAllAnnotationsOfTypeAsync(
            AnnotationTypeAdapter.fromString(
                type
            ), pageIndex.toInt(), 1
        ).subscribeOn(Schedulers.computation()).observeOn(AndroidSchedulers.mainThread())
            .subscribe({ annotation ->
                jsonArray.put(org.json.JSONObject(annotation.toInstantJson()))
            }, { throwable ->
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error while retrieving annotation of type $type",
                            throwable.message ?: "",
                        )
                    )
                )
            }, {
                callback(Result.success(jsonArray.toString()))
            })
    }

    override fun getAllUnsavedAnnotationsJson(callback: (Result<String?>) -> Unit) {

        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val document = Preconditions.requireDocumentNotNull(
            activityPluginBinding?.activity as PdfActivity, "Pspdfkit.getAllUnsavedAnnotationsJson()"
        )

        val outputStream = ByteArrayOutputStream()
        disposable = DocumentJsonFormatter.exportDocumentJsonAsync(document, outputStream)
            .subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread()).subscribe({
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

    override fun updateAnnotation(annotation: String, callback: (Result<Unit>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val document = Preconditions.requireDocumentNotNull(
            activityPluginBinding?.activity as PdfActivity, "Pspdfkit.updateAnnotation()"
        )

        try {
            val annotationObject:Map<String, *>  = Json.parseToJsonElement(annotation).jsonObject.toMap()
            //  Remove escaped backslashes from the JSON string.
            val pageIndex = annotationObject["pageIndex"] as Int
            val uid = annotationObject["uid"] as String

            val allAnnotations = document.annotationProvider.getAnnotations(pageIndex)
            val annotationInstance = allAnnotations.firstOrNull { it.uuid == uid }
            if (annotationInstance == null) {
                callback(Result.failure(Exception("Annotation not found")))
                return
            }
            document.annotationProvider.removeAnnotationFromPage(annotationInstance)
            disposable = document.annotationProvider.createAnnotationFromInstantJsonAsync(annotation)
                .subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                    {
                        callback(Result.success(Unit))
                    }
                ) { throwable ->
                    callback(
                        Result.failure(
                            NutrientApiError(
                                "Error while updating annotation",
                                throwable.message ?: "",
                            )
                        )
                    )
                }
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }

    override fun processAnnotations(
        type: com.pspdfkit.flutter.pspdfkit.api.AnnotationType,
        processingMode: AnnotationProcessingMode,
        destinationPath: String,
        callback: (Result<Boolean?>) -> Unit
    ) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val document = Preconditions.requireDocumentNotNull(
            activityPluginBinding?.activity as PdfActivity, "Pspdfkit.processAnnotations()"
        )
        val annotationType = annotationTypeFromString(type.name)
        val annotationProcessingMode = processModeFromString(processingMode.name)

        val task = if (type == com.pspdfkit.flutter.pspdfkit.api.AnnotationType.NONE) {
            PdfProcessorTask.fromDocument(document).changeAllAnnotations(annotationProcessingMode)
        } else {
            PdfProcessorTask.fromDocument(document)
                .changeAnnotationsOfType(annotationType, annotationProcessingMode)
        }

        disposable = PdfProcessor.processDocumentAsync(task, File(destinationPath))
            .subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread())
            .subscribeWith(object : DisposableSubscriber<ProcessorProgress?>() {
                override fun onComplete() {
                    callback(Result.success(true))
                }

                override fun onNext(t: ProcessorProgress?) {
                    // Notify the progress.
                }

                override fun onError(t: Throwable) {
                    callback(
                        Result.failure(
                            NutrientApiError(
                                "Error", "Error while processing annotations", t.message
                            )
                        )
                    )
                }
            })
    }

    override fun importXfdf(xfdfString: String, callback: (Result<Boolean?>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val document = Preconditions.requireDocumentNotNull(
            activityPluginBinding?.activity as PdfActivity, "Pspdfkit.processAnnotations()"
        )

        val dataProvider = DocumentJsonDataProvider(xfdfString)
        // The async parse method is recommended (so you can easily offload parsing from the UI thread).
        disposable = XfdfFormatter.parseXfdfAsync(document, dataProvider)
            .subscribeOn(Schedulers.io()) // Specify the thread on which to parse XFDF.
            .subscribe { annotations ->
                // Annotations parsed from XFDF aren't added to the document automatically.
                // You need to add them manually.
                for (annotation in annotations) {
                    document.annotationProvider.addAnnotationToPage(annotation)
                }
            }

    }

    override fun exportXfdf(xfdfPath: String, callback: (Result<Boolean?>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val document = Preconditions.requireDocumentNotNull(
            activityPluginBinding?.activity as PdfActivity, "Pspdfkit.processAnnotations()"
        )
        // Output stream pointing to the XFDF file into which to write the data.
        val outputStream = FileOutputStream(xfdfPath)

        // The async `write` method is recommended (so you can easily offload writing from the UI thread).
        disposable = XfdfFormatter.writeXfdfAsync(
            document, listOf(), listOf(), outputStream
        ).subscribeOn(Schedulers.io()) // Specify the thread on which to write XFDF.
            .subscribe({
                // XFDF was successfully written.
                callback(Result.success(true))
            }, { throwable ->
                // An error occurred while writing XFDF.
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error while exporting XFDF",
                            throwable.message ?: "",
                        )
                    )
                )
            })
    }

    override fun save(callback: (Result<Boolean?>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val document = Preconditions.requireDocumentNotNull(
            activityPluginBinding?.activity as PdfActivity, "Pspdfkit.save()"
        )
        disposable = document.saveIfModifiedAsync().subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe { result: Boolean -> callback(Result.success(result)) }
    }

    override fun setDelayForSyncingLocalChanges(
        delay: Double, callback: (Result<Boolean?>) -> Unit
    ) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }

        val document = Preconditions.requireDocumentNotNull(
            instantActivity, "Pspdfkit.setDelayForSyncingLocalChanges()"
        )
        (document as InstantPdfDocument).delayForSyncingLocalChanges = delay.toLong()
        callback(Result.success(true))
    }

    override fun setListenToServerChanges(listen: Boolean, callback: (Result<Boolean?>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }

        val document = Preconditions.requireDocumentNotNull(
            instantActivity, "Pspdfkit.setListenToServerChanges()"
        )
        (document as InstantPdfDocument).setListenToServerChanges(listen)
        callback(Result.success(true))
    }

    override fun syncAnnotations(callback: (Result<Boolean?>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }

        val document = Preconditions.requireDocumentNotNull(
            instantActivity, "Pspdfkit.syncAnnotations()"
        )
        disposable =
            (document as InstantPdfDocument).syncAnnotationsAsync().subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({ _: InstantProgress -> callback(Result.success(true)) },
                    { throwable: Throwable ->
                        callback(
                            Result.failure(
                                NutrientApiError(
                                    "Error", "Error while syncing annotations", throwable.message
                                )
                            )
                        )
                    })
    }

    override fun checkAndroidWriteExternalStoragePermission(callback: (Result<Boolean?>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }

        val permission = Manifest.permission.WRITE_EXTERNAL_STORAGE
        val status =
            checkPermission(activityPluginBinding?.activity as FragmentActivity, permission)
        callback(Result.success(status))
    }

    override fun requestAndroidWriteExternalStoragePermission(callback: (Result<AndroidPermissionStatus>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }

        val permission = Manifest.permission.WRITE_EXTERNAL_STORAGE
        requestPermission(activityPluginBinding?.activity as FragmentActivity, permission)
        callback(Result.success(AndroidPermissionStatus.NOT_DETERMINED))
    }

    override fun openAndroidSettings(callback: (Result<Unit>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }

        openSettings(activityPluginBinding?.activity as FragmentActivity)
        callback(Result.success(Unit))
    }

    override fun setAnnotationPresetConfigurations(
        configurations: Map<String, Any?>, callback: (Result<Boolean?>) -> Unit
    ) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val annotationConfigurations = configurations as Map<*, *>
        val parsedConfigurations: List<FlutterAnnotationPresetConfiguration> =
            convertAnnotationConfigurations(instantActivity, annotationConfigurations)

        val pdfFragment = instantActivity.pdfFragment
        for (config in parsedConfigurations) {
            if (config.annotationTool != null && config.variant != null) {
                pdfFragment.annotationConfiguration.put(
                    config.annotationTool, config.variant, config.configuration
                )
            }
            if (config.annotationTool != null && config.type == null) {
                pdfFragment.annotationConfiguration.put(
                    config.annotationTool, config.configuration
                )
            }
            if (config.type != null) {
                pdfFragment.annotationConfiguration.put(
                    config.type, config.configuration
                )
            }
        }
        callback(Result.success(true))
    }

    override fun getTemporaryDirectory(callback: (Result<String>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        callback(Result.success(getTemporaryDirectory(activityPluginBinding?.activity as FragmentActivity)))
    }

    override fun setAuthorName(name: String, callback: (Result<Unit>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        PSPDFKitPreferences.get(activityPluginBinding?.activity as FragmentActivity)
            .setAnnotationCreator(name)
        callback(Result.success(Unit))
    }

    override fun getAuthorName(callback: (Result<String>) -> Unit) {
        checkNotNull(activityPluginBinding) { "ActivityPluginBinding is null" }
        val authorName =
            PSPDFKitPreferences.get(activityPluginBinding?.activity as FragmentActivity)
                .getAnnotationCreator("")
        callback(Result.success(authorName ?: ""))
    }

    override fun generatePdf(
        pages: List<Map<String, Any>>,
        outputPath: String,
        callback: (Result<String?>) -> Unit
    ) {

        val adaptor = PdfPageAdaptor(activityPluginBinding!!.activity)
        val documentPages = adaptor.parsePages(pages)
        val task = PdfProcessorTask.empty()

        documentPages.forEachIndexed { index, newPage ->
            task.addNewPage(newPage, index)
        }

        val outputFile = File(outputPath)
        disposable = PdfProcessor
            .processDocumentAsync(task, outputFile)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe({
                //Log progress
                //Log.d("PDF Generation", "generatePdf: Processing page ${it.pagesProcessed + 1} of ${it.totalPages}")
            }, { throwable ->
                // Handle the error.
                callback(Result.failure(NutrientApiError("Error generating PDF", throwable.message)))
            }, {  // Handle the completion.
                callback(Result.success(outputPath))
            })
    }

    override fun generatePdfFromHtmlString(
        html: String,
        outPutFile: String,
        options: Map<String, Any>?,
        callback: (Result<String?>) -> Unit
    ) {

        val outputFile = File(outPutFile)// Output file for the converted PDF.

        val converter = if (options?.contains("baseUrl") == true) activityPluginBinding?.let {
            HtmlToPdfConverter.fromHTMLString(
                it.activity,
                html,
                options["baseUrl"] as String
            )
        } else activityPluginBinding?.let { HtmlToPdfConverter.fromHTMLString(it.activity, html, options?.get("baseUrl") as String) }

        if (options?.contains("enableJavaScript") == true)
            converter?.setJavaScriptEnabled(options["enableJavaScript"] as Boolean)

        if (options?.contains("documentTitle") == true)
            converter?.title(options["documentTitle"] as String)

        disposable = converter
            // Perform the conversion.
            ?.convertToPdfAsync(outputFile)
            ?.subscribeOn(Schedulers.io())
            // Publish results on the main thread so we can update the UI.
            ?.observeOn(AndroidSchedulers.mainThread())
            ?.subscribe(
                {
                    callback(Result.success(outputFile.absolutePath))
                },
                {
                    callback(Result.failure(NutrientApiError("HTML_TO_PDF_ERROR", it.message)))
                })
    }

    override fun generatePdfFromHtmlUri(
        htmlUri: String,
        outPutFile: String,
        options: Map<String, Any>?,
        callback: (Result<String?>) -> Unit
    ) {
        val outputFile = File(outPutFile)// Output file for the converted PDF.
        val convertor = activityPluginBinding?.let {
            HtmlToPdfConverter.fromUri(
                it.activity,
                htmlUri.toUri()
            )
        }

        // Configure javascript enabled
        if (options?.contains("enableJavaScript") == true) {
            convertor?.setJavaScriptEnabled(options["enableJavaScript"] as Boolean)
        }

        // Configure title for the created document.
        if (options?.contains("documentTitle") == true) {
            convertor?.title(options["documentTitle"] as String)
        }

        convertor?.let {
            disposable = it
                // Perform the conversion.
                .convertToPdfAsync(outputFile)
                // Subscribe to the conversion result.
                .subscribe({
                    // Return the converted document.
                    callback(Result.success(outputFile.absolutePath))
                }, { throwable ->
                    // Handle the error.
                    callback(Result.failure(NutrientApiError("", throwable.message)))
                })
        }
    }

    override fun enableAnalyticsEvents(enable: Boolean) {
        if (enable) {
            analyticsEventClient?.let { PSPDFKit.addAnalyticsClient(it) }
        } else {
            analyticsEventClient?.let { PSPDFKit.removeAnalyticsClient(it) }
        }
    }

    private fun setLicenseKey(activity: FragmentActivity, licenseKey: String?) {
        try {
            Nutrient.initialize(
                activity, InitializationOptions(
                    licenseKey,
                    listOf(),
                    CrossPlatformTechnology.Flutter,
                )
            )
        } catch (e: NutrientException) {
            throw IllegalStateException("Error while setting license key", e)
        }
    }

    private fun getTemporaryDirectory(
        activity: FragmentActivity
    ): String {
        return activity.cacheDir.path
    }

    private fun requestPermission(
        activity: FragmentActivity, permission: String?
    ) {
        val permissionResult: String? = getManifestPermission(permission)
        if (permission == null) {
            return
        }
        val perm = arrayOf(permissionResult)
        ActivityCompat.requestPermissions(activity, perm, 0)
    }

    private fun checkPermission(
        activity: FragmentActivity, permission: String?
    ): Boolean {
        val permissionResult: String = getManifestPermission(permission) ?: return false
        return (PackageManager.PERMISSION_GRANTED == ContextCompat.checkSelfPermission(
            activity,
            permissionResult
        ))
    }

    private fun getManifestPermission(permission: String?): String? {
        val res: String? = if ("WRITE_EXTERNAL_STORAGE" == permission) {
            Manifest.permission.WRITE_EXTERNAL_STORAGE
        } else {
            null
        }
        return res
    }

    private fun openSettings(activity: FragmentActivity) {
        val intent = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.parse("package:" + activity.packageName)
        )
        intent.addCategory(Intent.CATEGORY_DEFAULT)
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        activity.startActivity(intent)
    }

    override fun setAnnotationMenuConfiguration(
        configuration: AnnotationMenuConfigurationData,
        callback: (Result<Boolean?>) -> Unit
    ) {
        try {
            // Store the configuration globally for use with PspdfkitPluginMethodCallHandler (deprecated)
            GlobalAnnotationMenuConfiguration.setConfiguration(configuration)
            
            callback(Result.success(true))
        } catch (e: Exception) {
            callback(Result.failure(NutrientApiError("Error setting annotation menu configuration", e.message)))
        }
    }

    private val instantActivity: FlutterInstantPdfActivity
        get() {
            val instantPdfActivity = FlutterInstantPdfActivity.currentActivity
                ?: throw IllegalStateException("No instant activity found")
            return instantPdfActivity
        }
}