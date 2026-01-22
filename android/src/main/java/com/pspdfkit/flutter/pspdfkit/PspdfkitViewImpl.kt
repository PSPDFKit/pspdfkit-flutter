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
import com.pspdfkit.document.processor.PdfProcessor.ProcessorProgress
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
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.schedulers.Schedulers
import io.reactivex.rxjava3.subscribers.DisposableSubscriber
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.nio.charset.StandardCharsets
import java.util.Locale

class PspdfkitViewImpl : NutrientViewControllerApi {
    private var pdfUiFragment: PdfUiFragment? = null
    private var disposable: Disposable? = null
    private var eventDispatcher: FlutterEventsHelper? = null

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
            
            // Dispose of any ongoing operations
            disposable?.dispose()
            disposable = null
            
            // Clear references to prevent memory leaks
            eventDispatcher = null
            pdfUiFragment = null
        } catch (e: Exception) {
            // Log the error but don't throw - we want dispose to always complete
            android.util.Log.w("PspdfkitViewImpl", "Error during dispose", e)
            
            // Ensure critical cleanup still happens even if there's an error
            try {
                disposable?.dispose()
            } catch (disposableError: Exception) {
                android.util.Log.w("PspdfkitViewImpl", "Error disposing disposable", disposableError)
            }
            
            disposable = null
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
        // noinspection checkResult
        document.formProvider
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
        checkNotNull(pdfUiFragment)
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        disposable = document.formProvider
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
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
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
        checkNotNull(pdfUiFragment) { "PdfFragment is not set" }
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        val outputStream = ByteArrayOutputStream()

        // noinspection checkResult
        DocumentJsonFormatter.exportDocumentJsonAsync(document, outputStream)
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
        callback: (Result<Boolean?>) -> Unit
    ) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        disposable =
            document.annotationProvider.createAnnotationFromInstantJsonAsync(jsonAnnotation)
                .subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                    {
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

    override fun removeAnnotation(jsonAnnotation: String, callback: (Result<Boolean?>) -> Unit) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        //Annotation from JSON.
        val annotation = document.annotationProvider.createAnnotationFromInstantJson(jsonAnnotation)
        document.annotationProvider.removeAnnotationFromPage(annotation)
        callback(Result.success(true))
    }

    override fun getAnnotationsJson(pageIndex: Long, type: String, callback: (Result<String>) -> Unit) {
        checkNotNull(pdfUiFragment) { "PdfFragment is not set" }
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)

        val jsonArray = org.json.JSONArray()
        // noinspection checkResult
        document.annotationProvider.getAllAnnotationsOfTypeAsync(
            AnnotationTypeAdapter.fromString(
                type
            ),
            pageIndex.toInt(), 1
        )
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { annotation ->
                    jsonArray.put(org.json.JSONObject(annotation.toInstantJson()))
                },
                { throwable ->
                    callback(
                        Result.failure(
                            NutrientApiError(
                                "Error while retrieving annotation of type $type",
                                throwable.message ?: "",
                            )
                        )
                    )
                },
                {
                    callback(Result.success(jsonArray.toString()))
                }
            )
    }

    override fun getAllUnsavedAnnotationsJson(callback: (Result<String>) -> Unit) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        val outputStream = ByteArrayOutputStream()
        disposable = DocumentJsonFormatter.exportDocumentJsonAsync(document, outputStream)
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
        disposable = PdfProcessor.processDocumentAsync(task, outputPath)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeWith(object : DisposableSubscriber<ProcessorProgress?>() {
                override fun onComplete() {
                    callback(Result.success(true))
                }

                override fun onNext(t: ProcessorProgress?) {
                    // No-op
                }

                override fun onError(t: Throwable) {
                    callback(
                        Result.failure(
                            NutrientApiError(
                                "Error while processing annotations",
                                t.message ?: "",
                            )
                        )
                    )
                }
            })
    }

    override fun importXfdf(xfdfString: String, callback: (Result<Boolean>) -> Unit) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
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

    override fun exportXfdf(xfdfPath: String, callback: (Result<Boolean>) -> Unit) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)

        // Output stream pointing to the XFDF file into which to write the data.
        val outputStream = FileOutputStream(xfdfPath)

        // The async `write` method is recommended (so you can easily offload writing from the UI thread).
        disposable = XfdfFormatter.writeXfdfAsync(
            document,
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

    override fun save(callback: (Result<Boolean>) -> Unit) {
        val document = requireNotNull(pdfUiFragment?.pdfFragment?.document)
        disposable = document.saveIfModifiedAsync()
            .subscribeOn(Schedulers.computation())
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