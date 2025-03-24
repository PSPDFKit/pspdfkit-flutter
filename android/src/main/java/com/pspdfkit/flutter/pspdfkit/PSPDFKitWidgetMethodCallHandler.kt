package com.pspdfkit.flutter.pspdfkit

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.RectF
import android.util.Log
import com.pspdfkit.annotations.AnnotationType
import com.pspdfkit.document.formatters.DocumentJsonFormatter
import com.pspdfkit.document.processor.PdfProcessor
import com.pspdfkit.document.processor.PdfProcessorTask
import com.pspdfkit.flutter.pspdfkit.AnnotationConfigurationAdaptor.Companion.convertAnnotationConfigurations
import com.pspdfkit.flutter.pspdfkit.util.DocumentJsonDataProvider
import com.pspdfkit.flutter.pspdfkit.util.Preconditions.requireNotNullNotEmpty
import com.pspdfkit.flutter.pspdfkit.util.ProcessorHelper.annotationTypeFromString
import com.pspdfkit.flutter.pspdfkit.util.ProcessorHelper.processModeFromString
import com.pspdfkit.flutter.pspdfkit.util.areValidIndexes
import com.pspdfkit.forms.ChoiceFormElement
import com.pspdfkit.forms.EditableButtonFormElement
import com.pspdfkit.forms.SignatureFormElement
import com.pspdfkit.forms.TextFormElement
import com.pspdfkit.ui.PdfFragment
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.schedulers.Schedulers
import io.reactivex.rxjava3.subscribers.DisposableSubscriber
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.File

/**
 * Handles method calls from the Flutter side.
 * This class is responsible for handling method calls from the Flutter side.
 * However, it is marked as deprecated because we now use [PspdfkitViewImpl] instead for Flutter-Native communication.
 * This class has been kept for backward compatibility and will be removed in the future.
 */
@Deprecated("Use PspdfkitViewImpl instead")
class PSPDFKitWidgetMethodCallHandler(
    private val pdfFragment: PdfFragment
) :MethodCallHandler {
    companion object {
        private const val LOG_TAG = "PSPDFKitMethodHandler"
    }

    @SuppressLint("CheckResult")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // Return if the fragment or the document
        // are not ready.
        if (!pdfFragment.isAdded) {
            return
        }
        val document = pdfFragment.document ?: return

        when (call.method) {
            "applyInstantJson" -> {
                val annotationsJson: String? = call.argument("annotationsJson")
                val documentJsonDataProvider = DocumentJsonDataProvider(
                    requireNotNullNotEmpty(
                        annotationsJson,
                        "annotationsJson"
                    )
                )
                // noinspection checkResult
                DocumentJsonFormatter.importDocumentJsonAsync(document, documentJsonDataProvider)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { result.success(true) }
                    ) { throwable ->
                        result.error(
                            LOG_TAG,
                            "Error while importing document Instant JSON",
                            throwable.message
                        )
                    }
            }

            "exportInstantJson" -> {
                val outputStream = ByteArrayOutputStream()
                // noinspection checkResult
                DocumentJsonFormatter.exportDocumentJsonAsync(document, outputStream)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { result.success(outputStream.toString(java.nio.charset.StandardCharsets.UTF_8.name())) }
                    ) { throwable ->
                        result.error(
                            LOG_TAG,
                            "Error while exporting document Instant JSON",
                            throwable.message
                        )
                    }
            }

            "setFormFieldValue" -> {
                val value: String = requireNotNullNotEmpty(
                    call.argument("value"),
                    "Value"
                )
                val fullyQualifiedName = requireNotNullNotEmpty(
                    call.argument("fullyQualifiedName"),
                    "Fully qualified name"
                )
                // noinspection checkResult
                document.formProvider
                    .getFormElementWithNameAsync(fullyQualifiedName)
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { formElement ->
                            if (formElement is TextFormElement) {
                                formElement.setText(value)
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
                                val selectedIndexes: List<Int> = java.util.ArrayList<Int>()
                                if (areValidIndexes(value, selectedIndexes.toMutableList())) {
                                    formElement.selectedIndexes = selectedIndexes
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
                        { throwable ->
                            result.error(
                                LOG_TAG,
                                String.format(
                                    "Error while searching for a form element with name %s",
                                    fullyQualifiedName
                                ),
                                throwable.message
                            )
                        }
                    ) // Form element for the given name not found.
                    { result.success(false) }
            }

            "getFormFieldValue" -> {
                val fullyQualifiedName = requireNotNullNotEmpty(
                    call.argument("fullyQualifiedName"),
                    "Fully qualified name"
                )
                // noinspection checkResult
                document.formProvider
                    .getFormElementWithNameAsync(fullyQualifiedName)
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { formElement ->
                            when (formElement) {
                                is TextFormElement -> {
                                    val text: String = formElement.text ?: ""
                                    result.success(text)
                                }

                                is EditableButtonFormElement -> {
                                    val isSelected: Boolean =
                                        formElement.isSelected
                                    result.success(if (isSelected) "selected" else "deselected")
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
                                    result.success(stringBuilder.toString())
                                }

                                is SignatureFormElement -> {
                                    result.error(
                                        "Signature form elements are not supported.",
                                        null,
                                        null
                                    )
                                }

                                else -> {
                                    result.success(false)
                                }
                            }
                        },
                        { throwable ->
                            result.error(
                                LOG_TAG,
                                String.format(
                                    "Error while searching for a form element with name %s",
                                    fullyQualifiedName
                                ),
                                throwable.message
                            )
                        }
                    ) // Form element for the given name not found.
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
            }

            "addAnnotation" -> {
                val jsonAnnotation = requireNotNull(call.argument("jsonAnnotation"))

                val jsonString: String = when (jsonAnnotation) {
                    is HashMap<*, *> -> {
                        JSONObject(jsonAnnotation).toString()
                    }

                    is String -> {
                        jsonAnnotation
                    }

                    else -> {
                        result.error(
                            LOG_TAG,
                            "Invalid JSON Annotation.", jsonAnnotation
                        )
                        return
                    }
                }
                // noinspection checkResult
                document.annotationProvider.createAnnotationFromInstantJsonAsync(jsonString)
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { result.success(true) }
                    ) { throwable ->
                        result.error(
                            LOG_TAG,
                            "Error while creating annotation from Instant JSON",
                            throwable.message
                        )
                    }
            }

            "getAnnotations" -> {
                val pageIndex: Int = requireNotNull(call.argument("pageIndex"))
                val type: String = requireNotNull(call.argument("type"))

                val annotationJsonList = ArrayList<String>()
                // noinspection checkResult
                document.annotationProvider.getAllAnnotationsOfTypeAsync(
                    AnnotationTypeAdapter.fromString(
                        type
                    ),
                    pageIndex, 1
                )
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { annotation ->
                            annotationJsonList.add(annotation.toInstantJson())
                        },
                        { throwable ->
                            result.error(
                                LOG_TAG,
                                "Error while retrieving annotation of type $type",
                                throwable.message
                            )
                        },
                        { result.success(annotationJsonList) }
                    )
            }

            "getAllUnsavedAnnotations" -> {
                val outputStream = ByteArrayOutputStream()
                // noinspection checkResult
                DocumentJsonFormatter.exportDocumentJsonAsync(document, outputStream)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe({
                        val jsonString: String = outputStream.toString()
                        result.success(jsonString)
                    }, { throwable ->
                        result.error(
                            LOG_TAG,
                            "Error while getting unsaved JSON annotations.",
                            throwable.message
                        )
                    })
            }

            "save" -> {
                // noinspection checkResult
                document.saveIfModifiedAsync()
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(result::success)
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
                        convertAnnotationConfigurations(pdfFragment.requireContext(), annotationConfigurations)

                    for (config in configurations) {
                        if (config.annotationTool != null && config.variant != null) {
                            pdfFragment.annotationConfiguration.put(
                                config.annotationTool,
                                config.variant,
                                config.configuration
                            )
                        }
                        if (config.annotationTool != null && config.type == null) {
                            pdfFragment.annotationConfiguration.put(
                                config.annotationTool,
                                config.configuration
                            )
                        }
                        if (config.type != null) {
                            pdfFragment.annotationConfiguration.put(
                                config.type,
                                config.configuration
                            )
                        }
                    }
                    result.success(true)
                } catch (e: java.lang.Exception) {
                    result.error("AnnotationException", e.message, null)
                }
            }
            "getPageInfo" -> {
                try {
                    val pageIndex:Int = requireNotNull(call.argument("pageIndex"))
                    val pageInfo = mapOf(
                            "width" to document.getPageSize(pageIndex).width,
                            "height" to document.getPageSize(pageIndex).height,
                            "label" to document.getPageLabel(pageIndex,false),
                            "index" to pageIndex,
                            "rotation" to document.getPageRotation(pageIndex)
                    )
                    result.success(pageInfo)
                }catch (e:Exception){
                    result.error("DocumentException",e.message,null)
                }
            }
            "exportPdf" -> {
                try {
                    val fileUrl = document.documentSource.fileUri?.path
                    if (fileUrl == null) {
                        result.error("DocumentException", "Document source is not a file", null)
                        return
                    }
                    val data:ByteArray = fileUrl.let { File(it).readBytes() }
                    result.success(data)
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Error while exporting PDF", e)
                    result.error("DocumentException", e.message, null)
                }
            }
            "zoomToRect" -> {
                try {
                    val pageIndex:Int = requireNotNull(call.argument("pageIndex"))
                    val rect: Map<String,Double> = requireNotNull(call.argument("rect"))
                    var duration:Long = 0
                    if(call.hasArgument("duration")){
                        duration = requireNotNull(call.argument("duration"))
                    }
                    val x = requireNotNull(rect["left"])
                    val y = requireNotNull(rect["top"])
                    val width = requireNotNull(rect["width"])
                    val height = requireNotNull(rect["height"])
                    val zooRect = RectF(x.toFloat(),y.toFloat(),(x+width).toFloat(),(y+height).toFloat())
                    pdfFragment.zoomTo(zooRect,pageIndex, duration)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("DocumentException", e.message, null)
                }
            }
            "getVisibleRect" -> {
                val pageIndex = requireNotNull(call.argument("pageIndex")) as Int
                if (pageIndex < 0 || pageIndex >= document.pageCount) {
                    result.error("InvalidArgument", "pageIndex is required", null)
                } else {
                    val visiblePdfRect = RectF()
                    pdfFragment.getVisiblePdfRect(visiblePdfRect, pageIndex)
                    result.success(
                        mapOf(
                            "left" to visiblePdfRect.left,
                            "top" to visiblePdfRect.top,
                            "height" to visiblePdfRect.height(),
                            "width" to visiblePdfRect.width()
                        )
                    )
                }
            }
            "getZoomScale" -> {
                val pageIndex = requireNotNull(call.argument("pageIndex")) as Int
                if (pageIndex < 0 || pageIndex >= document.pageCount) {
                    result.error("InvalidArgument", "pageIndex is out of bounds", null)
                } else {
                    val zoomScale = pdfFragment.getZoomScale(pageIndex)
                    result.success(zoomScale)
                }
            }
            "processAnnotations" -> {
                val outputFilePath:String? = call.argument<String>("destinationPath")
                val annotationTypeString:String? = call.argument<String>("type")
                val processingModeString:String? = call.argument<String>("processingMode")

                // Check if the output path is valid.
                if (outputFilePath.isNullOrEmpty()) {
                    result.error("InvalidArgument", "Output path must be a valid string", null)
                    return
                }

                // Check if the annotation type is valid.
                if (annotationTypeString.isNullOrEmpty()) {
                    result.error("InvalidArgument", "Annotation type must be a valid string", null)
                    return
                }

                // Check if the processing mode is valid.
                if (processingModeString.isNullOrEmpty()) {
                    result.error("InvalidArgument", "Processing mode must be a valid string", null)
                    return
                }

                // Get the annotation type and processing mode.
                val annotationType = annotationTypeFromString(
                    annotationTypeString
                )
                val processingMode = processModeFromString(processingModeString)
                val outputPath = File(outputFilePath)

                if (outputPath.parentFile?.exists() == true || outputPath.parentFile?.mkdirs() == true) {
                    Log.d(LOG_TAG, "Output path is valid: $outputPath")
                } else {
                    result.error("InvalidArgument", "Output path ${outputPath.absolutePath} is invalid", null)
                    return
                }

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
                    .subscribeWith(object : DisposableSubscriber<PdfProcessor.ProcessorProgress?>() {
                        override fun onComplete() {
                            result.success(true)
                        }

                        override fun onNext(t: PdfProcessor.ProcessorProgress?) {
                            // No-op
                        }

                        override fun onError(t: Throwable) {
                            result.error("AnnotationException", t.message, null)
                        }
                    })
            }
            else -> result.notImplemented()
        }
    }
}