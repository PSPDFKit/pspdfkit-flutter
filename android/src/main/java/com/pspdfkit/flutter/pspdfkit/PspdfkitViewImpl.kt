/*
 * Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */
package com.pspdfkit.flutter.pspdfkit

import android.graphics.RectF
import android.util.Log
import com.pspdfkit.document.formatters.DocumentJsonFormatter
import com.pspdfkit.document.formatters.XfdfFormatter
import com.pspdfkit.document.processor.PdfProcessor
import com.pspdfkit.document.processor.PdfProcessorTask
import com.pspdfkit.flutter.pspdfkit.AnnotationConfigurationAdaptor.Companion.convertAnnotationConfigurations
import com.pspdfkit.flutter.pspdfkit.annotations.AnnotationUtils
import com.pspdfkit.flutter.pspdfkit.annotations.FlutterAnnotationPresetConfiguration
import com.pspdfkit.flutter.pspdfkit.api.AnnotationProcessingMode
import com.pspdfkit.flutter.pspdfkit.api.AnnotationTool
import com.pspdfkit.flutter.pspdfkit.api.AnnotationType
import com.pspdfkit.flutter.pspdfkit.api.NutrientApiError
import com.pspdfkit.flutter.pspdfkit.api.NutrientEvent
import com.pspdfkit.flutter.pspdfkit.api.NutrientViewControllerApi
import com.pspdfkit.flutter.pspdfkit.api.PdfRect
import com.pspdfkit.flutter.pspdfkit.events.FlutterEventsHelper
import com.pspdfkit.flutter.pspdfkit.util.DocumentJsonDataProvider
import com.pspdfkit.flutter.pspdfkit.util.Preconditions.requireNotNullNotEmpty
import com.pspdfkit.flutter.pspdfkit.util.ProcessorHelper.annotationTypeFromString
import com.pspdfkit.flutter.pspdfkit.util.ProcessorHelper.processModeFromString
import com.pspdfkit.flutter.pspdfkit.util.areValidIndexes
import com.pspdfkit.forms.ChoiceFormElement
import com.pspdfkit.forms.EditableButtonFormElement
import com.pspdfkit.forms.SignatureFormElement
import com.pspdfkit.forms.TextFormElement
import com.pspdfkit.ui.PdfUiFragment
import com.pspdfkit.flutter.pspdfkit.util.runCatchingUnlessCancelled
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.nio.charset.StandardCharsets
import java.util.Locale

class PspdfkitViewImpl : NutrientViewControllerApi {
    private var pdfUiFragment: PdfUiFragment? = null
    private var eventDispatcher: FlutterEventsHelper? = null
    // Results go to Flutter on the main thread. The SDK calls either dispatch their own work or are
    // moved off the main thread here.
    private val scope = MainScope()

    /**
     * Sets the PdfFragment to be used by the controller.
     *
     * @param pdfFragment The PdfFragment to be used by the controller.
     */
    fun setPdfFragment(pdfFragment: PdfUiFragment?) {
        this.pdfUiFragment = pdfFragment
    }

    fun setEventDispatcher(eventDispatcher: FlutterEventsHelper) {
        this.eventDispatcher = eventDispatcher
    }
    
    /**
     * Check if this view implementation has been properly disposed
     * 
     * @return true if disposed, false if still active
     */
    fun isDisposed(): Boolean {
        return pdfUiFragment == null && eventDispatcher == null
    }
    
    /**
     * Get the count of registered event listeners for debugging purposes
     * 
     * @return the number of registered listeners, or -1 if eventDispatcher is null
     */
    fun getEventListenerCount(): Int {
        return eventDispatcher?.getRegisteredListenersCount() ?: -1
    }

    /**
     * Disposes the controller and releases all resources.
     * Performs comprehensive cleanup to prevent memory leaks.
     */
    fun dispose() {
        try {
            // Clean up event listeners first, before nullifying pdfUiFragment
            eventDispatcher?.removeAllEventListeners(pdfUiFragment)
            
            // Calls already in progress still finish and reply, since Flutter is waiting for them.
            // They hold the document, not the fragment.

            // Clear references to prevent memory leaks
            eventDispatcher = null
            pdfUiFragment = null
        } catch (e: Exception) {
            // Log the error but don't throw - we want dispose to always complete
            android.util.Log.w("PspdfkitViewImpl", "Error during dispose", e)
            
            // Ensure critical cleanup still happens even if there's an error
            eventDispatcher = null
            pdfUiFragment = null
        }
    }

    override fun setFormFieldValue(
        value: String,
        fullyQualifiedName: String,
        callback: (Result<Boolean?>) -> Unit
    ) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        scope.launch {
            val formElement = runCatchingUnlessCancelled {
                document.formProvider.getFormElementWithName(fullyQualifiedName)
            }.getOrElse { throwable ->
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error while searching for a form element with name $fullyQualifiedName",
                            throwable.message ?: "",
                        )
                    )
                )
                return@launch
            }
            // Form element for the given name not found.
            if (formElement == null) {
                callback(Result.failure(NutrientApiError("Form element not found", "")))
                return@launch
            }
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
        }
    }

    override fun getFormFieldValue(
        fullyQualifiedName: String,
        callback: (Result<String?>) -> Unit
    ) {
        checkNotNull(pdfUiFragment)
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        scope.launch {
            val formElement = runCatchingUnlessCancelled {
                document.formProvider.getFormElementWithName(fullyQualifiedName)
            }.getOrElse { throwable ->
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error while searching for a form element with name $fullyQualifiedName",
                            throwable.message ?: "",
                        )
                    )
                )
                return@launch
            }
            // Form element for the given name not found.
            if (formElement == null) {
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Form field not found.",
                            "Form element with name $fullyQualifiedName not found"
                        )
                    )
                )
                return@launch
            }
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
        }
    }

    override fun applyInstantJson(annotationsJson: String, callback: (Result<Boolean?>) -> Unit) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        val documentJsonDataProvider = DocumentJsonDataProvider(
            requireNotNullNotEmpty(
                annotationsJson,
                "annotationsJson"
            )
        )
        scope.launch {
            runCatchingUnlessCancelled {
                // The formatter imports on the calling thread.
                withContext(Dispatchers.IO) { DocumentJsonFormatter.importDocumentJson(document, documentJsonDataProvider) }
            }.getOrElse { throwable ->
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Failed to apply Instant JSON",
                            throwable.message ?: "",
                        )
                    )
                )
                return@launch
            }
            callback(Result.success(true))
        }
    }

    override fun exportInstantJson(callback: (Result<String?>) -> Unit) {
        checkNotNull(pdfUiFragment) { "PdfFragment is not set" }
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        val outputStream = ByteArrayOutputStream()

        scope.launch {
            runCatchingUnlessCancelled {
                // The formatter exports on the calling thread.
                withContext(Dispatchers.IO) { DocumentJsonFormatter.exportDocumentJson(document, outputStream) }
            }.getOrElse { throwable ->
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Failed to export Instant JSON",
                            throwable.message ?: "",
                        )
                    )
                )
                return@launch
            }
            callback(Result.success(outputStream.toString(StandardCharsets.UTF_8.name())))
        }
    }

    override fun addAnnotation(
        jsonAnnotation: String,
        callback: (Result<Boolean?>) -> Unit
    ) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        scope.launch {
            try {
                withContext(Dispatchers.IO) {
                    document.annotationProvider.createAnnotationFromInstantJson(jsonAnnotation)
                }
                callback(Result.success(true))
            } catch (throwable: Throwable) {
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
    }

    override fun removeAnnotation(jsonAnnotation: String, callback: (Result<Boolean?>) -> Unit) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        scope.launch {
            try {
                val annotationJson = org.json.JSONObject(jsonAnnotation)
                val pageIndex = annotationJson.optInt("pageIndex", -1)
                val name = annotationJson.optString("name", null)
                val instantId = annotationJson.optString("id", null)

                if (pageIndex < 0) {
                    callback(Result.failure(NutrientApiError("InvalidAnnotation", "Annotation JSON missing pageIndex")))
                    return@launch
                }

                val annotation = withContext(Dispatchers.IO) {
                    val allAnnotations = document.annotationProvider.getAnnotations(pageIndex)
                    allAnnotations.firstOrNull { !name.isNullOrEmpty() && it.name == name }
                        ?: allAnnotations.firstOrNull { !instantId.isNullOrEmpty() && it.uuid == instantId }
                }

                if (annotation == null) {
                    callback(Result.failure(NutrientApiError("AnnotationNotFound", "Annotation not found")))
                    return@launch
                }
                withContext(Dispatchers.IO) {
                    document.annotationProvider.removeAnnotationFromPage(annotation)
                }
                callback(Result.success(true))
            } catch (e: Exception) {
                callback(Result.failure(NutrientApiError("RemoveAnnotationError", e.message ?: "")))
            }
        }
    }

    override fun getAnnotationsJson(pageIndex: Long, type: String, callback: (Result<String>) -> Unit) {
        checkNotNull(pdfUiFragment) { "PdfFragment is not set" }
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)

        scope.launch {
            try {
                val annotationTypeSet = AnnotationTypeAdapter.fromString(type)
                val annotations = withContext(Dispatchers.IO) {
                    document.annotationProvider.getAnnotations(pageIndex.toInt())
                }
                val filterAll = annotationTypeSet.contains(com.pspdfkit.annotations.AnnotationType.NONE)
                val filtered = if (filterAll) annotations else annotations.filter { annotationTypeSet.contains(it.type) }
                val jsonArray = org.json.JSONArray()
                filtered.forEach { annotation -> jsonArray.put(org.json.JSONObject(annotation.toInstantJson())) }
                callback(Result.success(jsonArray.toString()))
            } catch (throwable: Throwable) {
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error while retrieving annotation of type $type",
                            throwable.message ?: "",
                        )
                    )
                )
            }
        }
    }

    override fun getAllUnsavedAnnotationsJson(callback: (Result<String>) -> Unit) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        val outputStream = ByteArrayOutputStream()
        scope.launch {
            runCatchingUnlessCancelled {
                // The formatter exports on the calling thread.
                withContext(Dispatchers.IO) { DocumentJsonFormatter.exportDocumentJson(document, outputStream) }
            }.getOrElse { throwable ->
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error while getting unsaved JSON annotations.",
                            throwable.message ?: "",
                        )
                    )
                )
                return@launch
            }
            val jsonString: String = outputStream.toString()
            callback(Result.success(jsonString))
        }
    }

    override fun processAnnotations(
        type: AnnotationType,
        processingMode: AnnotationProcessingMode,
        destinationPath: String,
        callback: (Result<Boolean>) -> Unit
    ) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        // Get the annotation type and processing mode.
        val annotationType = annotationTypeFromString(
            type.name.lowercase()
        )
        val annotationProcessingMode =
            processModeFromString(processingMode.name.lowercase())
        val outputPath = File(destinationPath)

        if (outputPath.parentFile?.exists() != true && outputPath.parentFile?.mkdirs() != true) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "Invalid output path",
                        "Output path is invalid: $outputPath"
                    )
                )
            )
            return
        }
        // Check if we need to process all annotations or only annotations of a specific type.
        val task = if (annotationType == com.pspdfkit.annotations.AnnotationType.NONE) {
            PdfProcessorTask.fromDocument(document).changeAllAnnotations(annotationProcessingMode)
        } else {
            PdfProcessorTask.fromDocument(document)
                .changeAnnotationsOfType(annotationType, annotationProcessingMode)
        }
        scope.launch {
            runCatchingUnlessCancelled {
                PdfProcessor.processDocumentAsync(task, outputPath).flowOn(Dispatchers.IO).collect()
            }.getOrElse { t ->
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error while processing annotations",
                            t.message ?: "",
                        )
                    )
                )
                return@launch
            }
            callback(Result.success(true))
        }
    }

    override fun importXfdf(xfdfString: String, callback: (Result<Boolean>) -> Unit) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        val dataProvider = DocumentJsonDataProvider(xfdfString)
        scope.launch {
            try {
                val annotations: List<com.pspdfkit.annotations.Annotation> = withContext(Dispatchers.IO) {
                    XfdfFormatter.parseXfdfAsync(document, dataProvider)
                }
                withContext(Dispatchers.IO) {
                    for (annotation in annotations) {
                        document.annotationProvider.addAnnotationToPage(annotation)
                    }
                }
                callback(Result.success(true))
            } catch (e: Exception) {
                callback(Result.failure(NutrientApiError("Error importing XFDF", e.message ?: "")))
            }
        }
    }

    override fun exportXfdf(xfdfPath: String, callback: (Result<Boolean>) -> Unit) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)

        // Output stream pointing to the XFDF file into which to write the data.
        val outputStream = FileOutputStream(xfdfPath)

        scope.launch {
            runCatchingUnlessCancelled {
                // The formatter writes on the calling thread.
                withContext(Dispatchers.IO) {
                    XfdfFormatter.writeXfdfAsync(
                        document,
                        listOf(),
                        listOf(),
                        outputStream
                    )
                }
            }.getOrElse { throwable ->
                // An error occurred while writing XFDF.
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error while exporting XFDF",
                            throwable.message ?: "",
                        )
                    )
                )
                return@launch
            }
            // XFDF was successfully written.
            callback(Result.success(true))
        }
    }

    override fun save(callback: (Result<Boolean>) -> Unit) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        // The document saves off the main thread.
        scope.launch {
            runCatchingUnlessCancelled { document.saveIfModifiedAsync() }.getOrElse { throwable ->
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error while saving document",
                            throwable.message ?: "",
                        )
                    )
                )
                return@launch
            }
            callback(Result.success(true))
        }
    }

    override fun setAnnotationConfigurations(
        configurations: Map<String, Map<String, Any>>,
        callback: (Result<Boolean?>) -> Unit
    ) {
        val parsedConfigurations: List<FlutterAnnotationPresetConfiguration> =
            convertAnnotationConfigurations(pdfUiFragment!!.requireContext(), configurations)

        val pdfFragment = pdfUiFragment?.pdfFragment

        for (config in parsedConfigurations) {
            if (config.annotationTool != null && config.variant != null) {
                pdfFragment?.annotationConfiguration?.put(
                    config.annotationTool, config.variant, config.configuration
                )
            }
            if (config.annotationTool != null && config.type == null) {
                pdfFragment?.annotationConfiguration?.put(
                    config.annotationTool, config.configuration
                )
            }
            if (config.type != null) {
                pdfFragment?.annotationConfiguration?.put(
                    config.type, config.configuration
                )
            }
        }
        callback(Result.success(true))
    }

    override fun getVisibleRect(pageIndex: Long, callback: (Result<PdfRect>) -> Unit) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)

        if (pageIndex < 0 || pageIndex >= document.pageCount) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "Invalid page index",
                        "Page index must be in the range [0, ${document.pageCount})"
                    )
                )
            )
        } else {
            val visiblePdfRect = RectF()
            pdfUiFragment?.pdfFragment?.getVisiblePdfRect(visiblePdfRect, pageIndex.toInt())
            val pdfRect = PdfRect(
                visiblePdfRect.left.toDouble(),
                visiblePdfRect.top.toDouble(),
                visiblePdfRect.width().toDouble(),
                visiblePdfRect.height().toDouble()
            )
            callback(Result.success(pdfRect))
        }
    }

    override fun zoomToRect(
        pageIndex: Long,
        rect: PdfRect,
        animated: Boolean?,
        duration: Double?,
        callback: (Result<Boolean>) -> Unit
    ) {
        checkNotNull(pdfUiFragment) { "PdfFragment is not set" }
        try {
            val x = requireNotNull(rect.x)
            val y = requireNotNull(rect.y)
            val width = requireNotNull(rect.width)
            val height = requireNotNull(rect.height)
            val zooRect =
                RectF(x.toFloat(), y.toFloat(), (x + width).toFloat(), (y + height).toFloat())
            pdfUiFragment?.pdfFragment?.zoomTo(zooRect, pageIndex.toInt(), duration?.toLong() ?: 0)
            callback(Result.success(true))
        } catch (e: Exception) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "Error while zooming to rect",
                        e.message ?: ""
                    )
                )
            )
        }
    }

    override fun getZoomScale(pageIndex: Long, callback: (Result<Double>) -> Unit) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        if (pageIndex < 0 || pageIndex >= document.pageCount) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "Invalid page index",
                        "Page index must be in the range [0, ${document.pageCount})"
                    )
                )
            )
        } else {
            val zoomScale = pdfUiFragment?.pdfFragment?.getZoomScale(pageIndex.toInt())
            if (zoomScale != null) {
                callback(Result.success(zoomScale.toDouble()))
            } else {
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error while getting zoom scale",
                            "Zoom scale is null"
                        )
                    )
                )
            }
        }
    }

    override fun addEventListener(event: NutrientEvent) {
        val fragment = pdfUiFragment
        if (fragment != null && eventDispatcher != null) {
            eventDispatcher?.setEventListener(fragment, event)
        }
    }

    override fun removeEventListener(event: NutrientEvent) {
        // Use defensive null-safe removal
        eventDispatcher?.removeEventListener(pdfUiFragment, event)
    }

    override fun enterAnnotationCreationMode(
        annotationTool: AnnotationTool?,
        callback: (Result<Boolean?>) -> Unit
    ) {
        val pdfFragment = pdfUiFragment?.pdfFragment
        if (pdfFragment == null) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "Error entering annotation creation mode",
                        "PDF fragment is null"
                    )
                )
            )
            return
        }

        try {
            // Convert the Flutter AnnotationTool to the corresponding Android AnnotationToolWithVariant
            val toolWithVariant = AnnotationUtils.getAndroidAnnotationToolWithVariantFromFlutterTool(annotationTool)

            if (toolWithVariant != null) {
                // Enter annotation creation mode with the specific tool and variant
                val androidTool = toolWithVariant.annotationTool
                val variant = toolWithVariant.variant

                if (variant != null) {
                    // If we have both tool and variant, use them together
                    pdfFragment.enterAnnotationCreationMode(androidTool, variant)
                } else {
                    // If we only have the tool, use it without a variant
                    pdfFragment.enterAnnotationCreationMode(androidTool)
                }
                callback(Result.success(true))
            } else if (annotationTool != null) {
                // If the tool was provided but couldn't be mapped, return an error
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Invalid annotation tool",
                            "The annotation tool '$annotationTool' is not supported"
                        )
                    )
                )
            } else {
                // If no tool was provided, just enter annotation creation mode with default tool
                pdfFragment.enterAnnotationCreationMode()
                callback(Result.success(true))
            }
        } catch (e: Exception) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "Error entering annotation creation mode",
                        e.message ?: "Unknown error"
                    )
                )
            )
        }
    }

    override fun exitAnnotationCreationMode(callback: (Result<Boolean?>) -> Unit) {
        val pdfFragment = pdfUiFragment?.pdfFragment
        if (pdfFragment == null) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "Error exiting annotation creation mode",
                        "PDF fragment is null"
                    )
                )
            )
            return
        }
        try {
            // Exit annotation creation mode
            pdfFragment.exitCurrentlyActiveMode()
            callback(Result.success(true))
        } catch (e: Exception) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "Error exiting annotation creation mode",
                        e.message ?: "Unknown error"
                    )
                )
            )
        }
    }

    override fun convertViewPointToPdfPoint(
        pageIndex: Long,
        point: com.pspdfkit.flutter.pspdfkit.api.PointF,
        callback: (Result<com.pspdfkit.flutter.pspdfkit.api.PointF>) -> Unit
    ) {
        val viewProjection = pdfUiFragment?.pdfFragment?.viewProjection
        if (viewProjection == null) {
            callback(Result.failure(NutrientApiError("Coordinate conversion failed", "PDF fragment or view projection not available")))
            return
        }
        val androidPoint = android.graphics.PointF(point.x.toFloat(), point.y.toFloat())
        viewProjection.toPdfPoint(androidPoint, pageIndex.toInt())
        callback(Result.success(com.pspdfkit.flutter.pspdfkit.api.PointF(x = androidPoint.x.toDouble(), y = androidPoint.y.toDouble())))
    }

    override fun convertPdfPointToViewPoint(
        pageIndex: Long,
        point: com.pspdfkit.flutter.pspdfkit.api.PointF,
        callback: (Result<com.pspdfkit.flutter.pspdfkit.api.PointF>) -> Unit
    ) {
        val viewProjection = pdfUiFragment?.pdfFragment?.viewProjection
        if (viewProjection == null) {
            callback(Result.failure(NutrientApiError("Coordinate conversion failed", "PDF fragment or view projection not available")))
            return
        }
        val androidPoint = android.graphics.PointF(point.x.toFloat(), point.y.toFloat())
        viewProjection.toViewPoint(androidPoint, pageIndex.toInt())
        callback(Result.success(com.pspdfkit.flutter.pspdfkit.api.PointF(x = androidPoint.x.toDouble(), y = androidPoint.y.toDouble())))
    }

    override fun setAnnotationMenuConfiguration(
        configuration: com.pspdfkit.flutter.pspdfkit.api.AnnotationMenuConfigurationData,
        callback: (Result<Boolean?>) -> Unit
    ) {
        try {
            val pdfFragment = pdfUiFragment as? FlutterPdfUiFragment
            if (pdfFragment == null) {
                callback(
                    Result.failure(
                        NutrientApiError(
                            "Error setting annotation menu configuration",
                            "PDF fragment is null or not a FlutterPdfUiFragment"
                        )
                    )
                )
                return
            }

            // Create a new annotation menu handler with the updated configuration
            val handler = com.pspdfkit.flutter.pspdfkit.annotations.AnnotationMenuHandler(
                pdfFragment.requireContext(),
                configuration
            )
            
            // Update the fragment's annotation menu handler
            // This will be used by the fragment's onPrepareContextualToolbar method
            pdfFragment.setAnnotationMenuHandler(handler)

            callback(Result.success(true))
        } catch (e: Exception) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "Error setting annotation menu configuration",
                        e.message ?: "Unknown error"
                    )
                )
            )
        }
    }
}