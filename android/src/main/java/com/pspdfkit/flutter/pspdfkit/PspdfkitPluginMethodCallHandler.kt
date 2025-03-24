package com.pspdfkit.flutter.pspdfkit

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.pspdfkit.Nutrient.VERSION
import com.pspdfkit.Nutrient.initialize
import com.pspdfkit.annotations.AnnotationType
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.document.formatters.DocumentJsonFormatter
import com.pspdfkit.document.processor.PdfProcessor
import com.pspdfkit.document.processor.PdfProcessor.ProcessorProgress
import com.pspdfkit.document.processor.PdfProcessorTask
import com.pspdfkit.exceptions.NutrientException
import com.pspdfkit.flutter.pspdfkit.AnnotationConfigurationAdaptor.Companion.convertAnnotationConfigurations
import com.pspdfkit.flutter.pspdfkit.FlutterInstantPdfActivity.Companion.setLoadedDocumentResult
import com.pspdfkit.flutter.pspdfkit.FlutterInstantPdfActivity.Companion.setMeasurementValueConfigurations
import com.pspdfkit.flutter.pspdfkit.PspdfkitHTMLConverter.generateFromHtmlString
import com.pspdfkit.flutter.pspdfkit.PspdfkitHTMLConverter.generateFromHtmlUri
import com.pspdfkit.flutter.pspdfkit.pdfgeneration.PdfPageAdaptor
import com.pspdfkit.flutter.pspdfkit.util.DocumentJsonDataProvider
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper.Companion.addMeasurementConfiguration
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper.Companion.getMeasurementConfigurations
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper.Companion.modifyMeasurementConfiguration
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper.Companion.removeMeasurementConfiguration
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
import com.pspdfkit.instant.ui.InstantPdfActivityIntentBuilder.Companion.fromInstantDocument
import com.pspdfkit.ui.PdfActivity
import com.pspdfkit.ui.PdfActivityIntentBuilder
import com.pspdfkit.ui.PdfFragment
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.schedulers.Schedulers
import io.reactivex.rxjava3.subscribers.DisposableSubscriber
import java.io.ByteArrayOutputStream
import java.io.File
import java.nio.charset.StandardCharsets
import java.util.Objects
import java.util.concurrent.atomic.AtomicReference

/**
 * Note: This class is deprecated and will be removed in the future releases. If you need to make any modifications, [PspdfkitApiImpl] instead.
 * Handles method calls from the Flutter side.
 * This class is responsible for handling method calls from the Flutter side and executing the
 * appropriate logic.
 * @param context The context of the application.
 * @param activityLifecycleCallback The activity lifecycle callback.
 *
 */
@Deprecated("Use PspdfkitApiImpl instead")
class PspdfkitPluginMethodCallHandler(private val context: Activity,
                                      private val activityLifecycleCallback: Application.ActivityLifecycleCallbacks): MethodCallHandler{

    private val currentActivity: PdfActivity? = null
    private val LOG_TAG: String = "PluginMethodCallHandler"
    private  var pdfFragment: PdfFragment? = null
    private var disposable: Disposable? = null
    var measurementValueConfigurations: List<Map<String, Any>>? = null
    fun setPdfFragment(pdfFragment: PdfFragment) {
        this.pdfFragment = pdfFragment
    }

    /**
     * Atomic reference that prevents sending twice the permission result and throwing exception.
     */
     val permissionRequestResult: AtomicReference<MethodChannel.Result> = AtomicReference()

    @SuppressLint("CheckResult")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val fullyQualifiedName: String?
        var document: PdfDocument

        when (call.method) {
            "frameworkVersion" -> {
                result.success("Android $VERSION")
            }
            "setLicenseKey" -> {
                val licenseKey = call.argument<String>("licenseKey")
                setLicenseKey( licenseKey)
            }

            "setLicenseKeys" -> {
                val androidLicenseKey = call.argument<String>("androidLicenseKey")
                setLicenseKey(androidLicenseKey);
            }

            "present" -> {
                var documentPath = call.argument<String>("document")
                Preconditions.requireNotNullNotEmpty(documentPath, "Document path")
                documentPath = addFileSchemeIfMissing(documentPath!!)

                val configurationMap = call.argument<HashMap<String, Any>>(
                    "configuration"
                )
                val configurationAdapter = ConfigurationAdapter(
                    context,
                    configurationMap
                )

                measurementValueConfigurations =
                    (configurationMap?.get("measurementValueConfigurations")) as List<Map<String, Any>>?

                context.application.registerActivityLifecycleCallbacks(activityLifecycleCallback)

                documentPath = addFileSchemeIfMissing(documentPath)
                FlutterPdfActivity.setLoadedDocumentResult(result)
                val imageDocument = isImageDocument(documentPath)
                val intent = if (imageDocument) {
                    PdfActivityIntentBuilder
                        .fromImageUri(context, Uri.parse(documentPath))
                        .activityClass(FlutterPdfActivity::class.java)
                        .configuration(configurationAdapter.build())
                        .build()
                } else {
                    PdfActivityIntentBuilder
                        .fromUri(context, Uri.parse(documentPath))
                        .activityClass(FlutterPdfActivity::class.java)
                        .configuration(configurationAdapter.build())
                        .passwords(configurationAdapter.password)
                        .build()
                }
                context.startActivity(intent)
            }

            "presentInstant" -> {
                val documentUrl = call.argument<String>("serverUrl")
                val jwt = call.argument<String>("jwt")

                Preconditions.requireNotNullNotEmpty(documentUrl, "Document path")
                Preconditions.requireNotNullNotEmpty(jwt, "JWT")

                val configurationMapInstant = call.argument<HashMap<String, Any>>(
                    "configuration"
                )!!

                val configurationAdapterInstant = ConfigurationAdapter(
                    context,
                    configurationMapInstant
                )
                val measurementValueConfigurationsInstant =
                    call.argument<List<Map<String, Any>>>("measurementValueConfigurations")!!

                setLoadedDocumentResult(result)
                setMeasurementValueConfigurations(measurementValueConfigurationsInstant)

                val intentInstant =
                    fromInstantDocument(context, documentUrl!!, jwt!!)
                        .activityClass(FlutterInstantPdfActivity::class.java)
                        .configuration(configurationAdapterInstant.build())
                        .build()

                context.startActivity(intentInstant)
            }

            "checkPermission" -> {
                val permissionToCheck = call.argument<String>("permission")
                if (permissionToCheck == null) {
                    result.error("InvalidArgument", "Permission must be a valid string", null)
                    return
                }
                result.success(checkPermission(context, permissionToCheck))
            }

            "requestPermission" -> {
                val permissionToRequest = call.argument<String>("permission")
                permissionRequestResult.set(result)
                if (permissionToRequest == null) {
                    result.error("InvalidArgument", "Permission must be a valid string", null)
                    return
                }
                requestPermission(context, permissionToRequest)
            }

            "openSettings" -> {
                openSettings(context)
                result.success(true)
            }

            "applyInstantJson" -> {
                val annotationsJson = call.argument<String>("annotationsJson")
                Preconditions.requireNotNullNotEmpty(annotationsJson, "annotationsJson")
                document =
                    Preconditions.requireDocumentNotNull(
                        getCurrentActivity(),
                        "Pspdfkit.applyInstantJson(String)"
                    )

                val documentJsonDataProvider = DocumentJsonDataProvider(
                    annotationsJson!!
                )
                DocumentJsonFormatter
                    .importDocumentJsonAsync(document, documentJsonDataProvider)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { result.success(true) },
                        { throwable: Throwable ->
                            result.error(
                                LOG_TAG,
                                "Error while importing document Instant JSON",
                                throwable.message
                            )
                        }
                    )
            }

            "exportInstantJson" -> {
                document =
                    Preconditions.requireDocumentNotNull(
                        getCurrentActivity(),
                        "Pspdfkit.exportInstantJson()"
                    )

                val outputStream = ByteArrayOutputStream()
                DocumentJsonFormatter
                    .exportDocumentJsonAsync(document, outputStream)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        {
                            result.success(
                                outputStream.toString(StandardCharsets.UTF_8.name())
                            )
                        },
                        { throwable: Throwable ->
                            result.error(
                                LOG_TAG,
                                "Error while exporting document Instant JSON",
                                throwable.message
                            )
                        }
                    )
            }

            "setFormFieldValue" -> {
                val value = call.argument<String>("value")
                fullyQualifiedName = call.argument("fullyQualifiedName")

                Preconditions.requireNotNullNotEmpty(value, "Value")
                Preconditions.requireNotNullNotEmpty(fullyQualifiedName, "Fully qualified name")
                document =
                    Preconditions.requireDocumentNotNull(
                        getCurrentActivity(),
                        "Pspdfkit.setFormFieldValue(String)"
                    )

                document
                    .formProvider
                    .getFormElementWithNameAsync(fullyQualifiedName!!)
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { formElement: FormElement? ->
                            if (formElement is TextFormElement) {
                                formElement.setText(value!!)
                                result.success(true)
                            } else if (formElement is EditableButtonFormElement) {
                                when (value) {
                                    "selected" -> {
                                        formElement.select()
                                        result.success(true)
                                    }
                                    "deselected" -> {
                                        formElement.deselect()
                                        result.success(true)
                                    }
                                    else -> {
                                        result.success(false)
                                    }
                                }
                            } else if (formElement is ChoiceFormElement) {
                                val selectedIndexes: MutableList<Int> = ArrayList()
                                if (areValidIndexes(value!!, selectedIndexes)) {
                                    formElement.selectedIndexes =
                                        selectedIndexes
                                    result.success(true)
                                } else {
                                    result.error(
                                        LOG_TAG,
                                        "\"value\" argument needs a list of " +
                                                "integers to set selected indexes for a choice " +
                                                "form element (e.g.: \"1, 3, 5\").",
                                        null
                                    )
                                }
                            } else if (formElement is SignatureFormElement) {
                                result.error(
                                    "Signature form elements are not supported.",
                                    null,
                                    null
                                )
                            } else {
                                result.success(false)
                            }
                        },
                        { throwable: Throwable ->
                            result.error(
                                LOG_TAG,
                                String.format(
                                    "Error while searching for a form element with name %s",
                                    fullyQualifiedName
                                ),
                                throwable.message
                            )
                        },  // Form element for the given name not found.
                        { result.success(false) }
                    )
            }

            "getFormFieldValue" -> {
                fullyQualifiedName = call.argument("fullyQualifiedName")

                Preconditions.requireNotNullNotEmpty(fullyQualifiedName, "Fully qualified name")
                document =
                    Preconditions.requireDocumentNotNull(
                        getCurrentActivity(),
                        "Pspdfkit.getFormFieldValue()"
                    )

                document
                    .formProvider
                    .getFormElementWithNameAsync(fullyQualifiedName!!)
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { formElement: FormElement? ->
                            if (formElement is TextFormElement) {
                                val text = formElement.text
                                result.success(text)
                            } else if (formElement is EditableButtonFormElement) {
                                val isSelected =
                                    formElement.isSelected
                                result.success(if (isSelected) "selected" else "deselected")
                            } else if (formElement is ChoiceFormElement) {
                                val selectedIndexes =
                                    formElement.selectedIndexes
                                val stringBuilder = StringBuilder()
                                val iterator: Iterator<Int> = selectedIndexes.iterator()
                                while (iterator.hasNext()) {
                                    stringBuilder.append(iterator.next())
                                    if (iterator.hasNext()) {
                                        stringBuilder.append(",")
                                    }
                                }
                                result.success(stringBuilder.toString())
                            } else if (formElement is SignatureFormElement) {
                                result.error(
                                    "Signature form elements are not supported.",
                                    null,
                                    null
                                )
                            } else {
                                result.success(false)
                            }
                        },
                        { throwable: Throwable ->
                            result.error(
                                LOG_TAG,
                                String.format(
                                    "Error while searching for a form element with name %s",
                                    fullyQualifiedName
                                ),
                                throwable.message
                            )
                        },  // Form element for the given name not found.
                        {
                            result.error(
                                LOG_TAG,
                                String.format(
                                    "Form element not found with name %s",
                                    fullyQualifiedName
                                ),
                                null
                            )
                        }
                    )
            }

            "save" -> {
                document =
                    Preconditions.requireDocumentNotNull(
                        getCurrentActivity(),
                        "Pspdfkit.save()"
                    )
                document
                    .saveIfModifiedAsync()
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe { it: Boolean -> result.success(it) }
            }

            "getTemporaryDirectory" -> {
                result.success(getTemporaryDirectory(context))
            }
            "generatePDF" -> {
                val adaptor = PdfPageAdaptor(context)
                val processor = PspdfkitPdfGenerator(adaptor)
                val pages = call.argument<List<HashMap<String, Any>>>("pages")
                val outputFilePath = call.argument<String>("outputFilePath")
                if (pages.isNullOrEmpty()) {
                    result.error("InvalidArgument", "Pages argument is null or empty", null)
                    return
                }
                Preconditions.requireNotNullNotEmpty(outputFilePath, "Output file path")
                processor.generatePdf(pages, outputFilePath!!, result)
            }

            "generatePdfFromHtmlString" -> {
                val html = call.argument<String>("html")
                val outputFilePath = call.argument<String>("outputPath")
                val options = call.argument<HashMap<String, Any>>("options")!!
                Preconditions.requireNotNullNotEmpty(html, "Html")
                Preconditions.requireNotNullNotEmpty(outputFilePath, "Output path")

                generateFromHtmlString(
                    context,
                    html!!,
                    outputFilePath!!,
                    options,
                    result
                )
            }

            "generatePdfFromHtmlUri" -> {
                val uriString = call.argument<String>("htmlUri")
                val outputFilePath = call.argument<String>("outputPath")
                val options = call.argument<HashMap<String, Any>>("options")!!

                Preconditions.requireNotNullNotEmpty(outputFilePath, "Output file path")
                Preconditions.requireNotNullNotEmpty(uriString, "Uri")
                generateFromHtmlUri(
                    context,
                    uriString!!,
                    outputFilePath!!,
                    options,
                    result
                )
            }

            "setDelayForSyncingLocalChanges" -> {
                val delay = call.argument<Double>("delay")
                if (delay == null || delay < 0) {
                    result.error("InvalidArgument", "Delay must be a positive number", null)
                    return
                }

                try {
                    document = Preconditions.requireDocumentNotNull(
                        getInstantActivity(),
                        "Pspdfkit.setDelayForSyncingLocalChanges()"
                    )
                    (document as InstantPdfDocument).delayForSyncingLocalChanges = delay.toLong()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("InstantException", e.message, null)
                }
            }

            "setListenToServerChanges" -> {
                try {
                    val listen = java.lang.Boolean.TRUE == call.argument("listen")
                    document = Preconditions.requireDocumentNotNull(
                        getInstantActivity(),
                        "Pspdfkit.setListenToServerChanges()"
                    )
                    (document as InstantPdfDocument).setListenToServerChanges(listen)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("InstantException", e.message, null)
                }
            }

            "syncAnnotations" -> {
                try {
                    document = Preconditions.requireDocumentNotNull(
                        getInstantActivity(),
                        "Pspdfkit.syncAnnotations()"
                    )
                    disposable = (document as InstantPdfDocument).syncAnnotationsAsync()
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(
                            { it: InstantProgress -> result.success(it) },
                            { throwable: Throwable ->
                                result.error(
                                    "InstantException",
                                    throwable.message,
                                    null
                                )
                            })
                } catch (e: Exception) {
                    result.error("InstantException", e.message, null)
                }
            }

            "addMeasurementValueConfiguration" -> {
                try {
                    val configuration =
                        call.argument<Map<String, Any>>("measurementValueConfiguration")
                    if (configuration == null) {
                        result.error(
                            "PSPDFKitMeasurementException",
                            "Invalid measurement configuration",
                            null
                        )
                        return
                    }
                    if (pdfFragment == null) {
                        result.error("PSPDFKitMeasurementException", "PdfFragment is null", null)
                        return
                    }
                    addMeasurementConfiguration(
                        pdfFragment!!,
                        configuration
                    )
                } catch (e: Exception) {
                    result.error("PSPDFKitMeasurementException", e.message, null)
                }
            }

            "getMeasurementValueConfiguration" -> {
                try {
                    if (pdfFragment == null) {
                        result.error("PSPDFKitMeasurementException", "PdfFragment is null", null)
                        return
                    }
                    val measurementConfigurations =
                        getMeasurementConfigurations(pdfFragment!!)
                    result.success(measurementConfigurations)
                } catch (e: Exception) {
                    result.error("PSPDFKitMeasurementException", e.message, null)
                }
            }

            "modifyMeasurementValueConfiguration" -> {
                try {
                    val args = call.argument<Map<String, Any>>("payload")
                    if (args == null) {
                        result.error(
                            "PSPDFKitMeasurementException",
                            "Invalid measurement configuration",
                            null
                        )
                        return
                    }
                    if (pdfFragment == null) {
                        result.error("PSPDFKitMeasurementException", "PdfFragment is null", null)
                        return
                    }
                    modifyMeasurementConfiguration(pdfFragment!!, args)
                } catch (e: Exception) {
                    result.error("PSPDFKitMeasurementException", e.message, null)
                }
            }

            "removeMeasurementValueConfiguration" -> {
                try {
                    val configuration = call.argument<Map<String, Any>>("payload")
                    if (configuration == null) {
                        result.error(
                            "PSPDFKitMeasurementException",
                            "Invalid measurement configuration",
                            null
                        )
                        return
                    }
                    if (pdfFragment == null) {
                        result.error("PSPDFKitMeasurementException", "PdfFragment is null", null)
                        return
                    }
                    removeMeasurementConfiguration(
                        pdfFragment!!,
                        configuration
                    )
                } catch (e: Exception) {
                    result.error("PSPDFKitMeasurementException", e.message, null)
                }
            }

            "setAnnotationConfigurations" -> {
                try {
                    val annotationConfigurations =
                        call.argument<Map<String?, Any?>>("annotationConfigurations")
                    if (annotationConfigurations == null) {
                        result.error(
                            "InvalidArgument",
                            "Annotation configurations must be a valid map",
                            null
                        )
                        return
                    }
                    val configurations =
                        convertAnnotationConfigurations(
                            getInstantActivity(),
                            annotationConfigurations
                        )

                    if (pdfFragment == null) {
                        result.error("InvalidState", "PdfFragment is null", null)
                        return
                    }

                    for ((type, annotationTool, variant, configuration) in configurations) {
                        if (annotationTool != null && variant != null) {
                            pdfFragment?.annotationConfiguration?.put(
                                annotationTool,
                                variant,
                                configuration
                            )
                        }
                        if (annotationTool != null && type == null) {
                            pdfFragment?.annotationConfiguration?.put(
                                annotationTool,
                                configuration
                            )
                        }
                        if (type != null) {
                            pdfFragment?.annotationConfiguration?.put(
                                type,
                                configuration
                            )
                        }
                    }
                    result.success(true)
                } catch (e: Exception) {
                    result.error("AnnotationException", e.message, null)
                }
            }

            "processAnnotations" -> {
                run {
                    val outputFilePath = call.argument<String>("destinationPath")
                    val annotationTypeString = call.argument<String>("type")
                    val processingModeString = call.argument<String>("processingMode")

                    // Check if the output path is valid.
                    if (outputFilePath.isNullOrEmpty()) {
                        result.error("InvalidArgument", "Output path must be a valid string", null)
                        return
                    }

                    // Check if the annotation type is valid.
                    if (annotationTypeString.isNullOrEmpty()) {
                        result.error(
                            "InvalidArgument",
                            "Annotation type must be a valid string",
                            null
                        )
                        return
                    }

                    // Check if the processing mode is valid.
                    if (processingModeString.isNullOrEmpty()) {
                        result.error(
                            "InvalidArgument",
                            "Processing mode must be a valid string",
                            null
                        )
                        return
                    }

                    // Get the annotation type and processing mode.
                    val annotationType = annotationTypeFromString(annotationTypeString)
                    val processingMode = processModeFromString(processingModeString)
                    val outputPath = File(outputFilePath)

                    if (Objects.requireNonNull(outputPath.parentFile)
                            .exists() || outputPath.parentFile?.mkdirs() == true
                    ) {
                        Log.d(LOG_TAG, "Output path is valid")
                    } else {
                        result.error(
                            "InvalidArgument",
                            "Output path " + outputPath.absolutePath + " is invalid",
                            null
                        )
                        return
                    }

                    document = Preconditions.requireDocumentNotNull(
                        getInstantActivity(),
                        "Pspdfkit.processAnnotations()"
                    )

                    // Check if we need to process all annotations or only annotations of a specific type.
                    val task = if (annotationType == AnnotationType.NONE) {
                        PdfProcessorTask.fromDocument(document).changeAllAnnotations(processingMode)
                    } else {
                        PdfProcessorTask.fromDocument(document)
                            .changeAnnotationsOfType(annotationType, processingMode)
                    }
                    PdfProcessor.processDocumentAsync(task, outputPath)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribeWith(object : DisposableSubscriber<ProcessorProgress?>() {
                            override fun onComplete() {
                                result.success(true)
                            }

                            override fun onNext(t: ProcessorProgress?) {
                                TODO("Not yet implemented")
                            }

                            override fun onError(t: Throwable) {
                                result.error("AnnotationException", t.message, null)
                            }
                        })
                }
                result.notImplemented()
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getCurrentActivity(): PdfActivity? {
        var pdfActivity: PdfActivity? = FlutterPdfActivity.getCurrentActivity()
        if (pdfActivity == null) {
            pdfActivity = currentActivity
        }
        return pdfActivity
    }

    private fun setLicenseKey(licenseKey: String?) {
        try {
            val options = InitializationOptions(
                licenseKey, java.util.ArrayList(),
                CrossPlatformTechnology.Flutter, null
            )
            initialize(context, options)
        } catch (e: NutrientException) {
            throw IllegalStateException("Error while setting license key", e)
        }
    }

    // Try tp get Current PdfActivity, this can be either [FlutterPdfActivity] or [FlutterInstantPdfActivity]
    private fun getInstantActivity(): FlutterInstantPdfActivity {
        val instantPdfActivity = FlutterInstantPdfActivity.currentActivity
        checkNotNull(instantPdfActivity) { "No instant activity found" }
        return instantPdfActivity
    }

    private fun requestPermission(
        activity: Activity,
        permission: String
    ) {
        val mPermission: String = getManifestPermission(permission) ?: return
        Log.i(LOG_TAG, "Requesting permission $mPermission")
        val perm = arrayOf(mPermission)
        ActivityCompat.requestPermissions(activity, perm, 0)
    }

    private fun checkPermission(
        context: Context,
        permission: String
    ): Boolean {
        val mPermission: String = getManifestPermission(permission) ?: return false
        Log.i(LOG_TAG, "Checking permission $mPermission")
        return (PackageManager.PERMISSION_GRANTED ==
                ContextCompat.checkSelfPermission(context, mPermission)
                )
    }


    private fun getTemporaryDirectory(
        activity: Context
    ): String {
        return activity.cacheDir.path
    }

    // Try tp get Current PdfActivity, this can be either [FlutterPdfActivity] or [FlutterInstantPdfActivity]
    private fun getManifestPermission(permission: String): String? {
        val res: String?
        if ("WRITE_EXTERNAL_STORAGE" == permission) {
            res = Manifest.permission.WRITE_EXTERNAL_STORAGE
        } else {
            Log.e(LOG_TAG, "Not implemented permission $permission")
            res = null
        }
        return res
    }

    private fun openSettings(context: Context) {
        val intent = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.parse("package:" + context.packageName)
        )
        intent.addCategory(Intent.CATEGORY_DEFAULT)
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    fun dispose() {
        disposable?.dispose()
        pdfFragment = null
    }
}