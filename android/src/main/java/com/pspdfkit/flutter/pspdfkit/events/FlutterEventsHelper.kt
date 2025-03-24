package com.pspdfkit.flutter.pspdfkit.events

import com.pspdfkit.annotations.Annotation
import com.pspdfkit.annotations.AnnotationProvider
import com.pspdfkit.datastructures.TextSelection
import com.pspdfkit.flutter.pspdfkit.api.NutrientEvent
import com.pspdfkit.flutter.pspdfkit.api.NutrientEventsCallbacks
import com.pspdfkit.ui.PdfUiFragment
import com.pspdfkit.ui.special_mode.controller.AnnotationSelectionController
import com.pspdfkit.ui.special_mode.manager.AnnotationManager
import com.pspdfkit.ui.special_mode.manager.FormManager
import com.pspdfkit.ui.special_mode.manager.TextSelectionManager

/**
 * Helper class to manage event listeners for Nutrient Flutter integration.
 * Handles registration and removal of event listeners for various PDF events.
 */
class FlutterEventsHelper(private val eventCallbacks: NutrientEventsCallbacks? = null) {

    // Map to store event listeners by event type
    private val eventsMap: MutableMap<NutrientEvent, Any> = mutableMapOf()

    /**
     * Register an event listener for the specified event type
     * 
     * @param pdfUiFragment The fragment to attach the listener to
     * @param event The event type to listen for
     */
    fun setEventListener(pdfUiFragment: PdfUiFragment, event: NutrientEvent) {
        // Don't add duplicate listeners
        if (eventsMap.containsKey(event)) {
            return
        }

        val pdfFragment = pdfUiFragment.pdfFragment ?: return

        when (event) {
            NutrientEvent.ANNOTATIONS_CREATED -> {
                createAnnotationListener(pdfFragment, event, 
                    onCreated = { annotation ->
                        sendEvent(event, mapOf("annotations" to listOf(annotation.toInstantJson())))
                    }
                )
            }
            NutrientEvent.ANNOTATIONS_UPDATED -> {
                createAnnotationListener(pdfFragment, event,
                    onUpdated = { annotation ->
                        sendEvent(event, mapOf("annotations" to listOf(annotation.toInstantJson())))
                    }
                )
            }
            NutrientEvent.ANNOTATIONS_DELETED -> {
                createAnnotationListener(pdfFragment, event,
                    onRemoved = { annotation ->
                        sendEvent(event, mapOf("deleted" to mapOf(
                            "name" to annotation.name,
                            "type" to annotation.type.name,
                            "id" to annotation.uuid
                        )))
                    }
                )
                pdfFragment.document?.invalidateCache()
            }
            NutrientEvent.ANNOTATIONS_SELECTED -> {
                val listener = object : AnnotationManager.OnAnnotationSelectedListener {
                    override fun onPrepareAnnotationSelection(
                        controller: AnnotationSelectionController,
                        annotation: Annotation,
                        isMultipleSelection: Boolean
                    ): Boolean = true

                    override fun onAnnotationSelected(
                        annotation: Annotation,
                        isMultipleSelection: Boolean
                    ) {
                        sendEvent(event, mapOf(
                            "annotation" to annotation.toInstantJson(),
                            "isMultipleSelection" to isMultipleSelection
                        ))
                    }
                }
                pdfFragment.addOnAnnotationSelectedListener(listener)
                eventsMap[event] = listener
            }
            NutrientEvent.ANNOTATIONS_DESELECTED -> {
                val listener = AnnotationManager.OnAnnotationDeselectedListener { annotation, isMultipleSelection ->
                    sendEvent(event, mapOf(
                        "deselected" to mapOf(
                            "name" to annotation.name,
                            "type" to annotation.type.name,
                            "id" to annotation.uuid,
                            "objectNumber" to annotation.objectNumber
                        ),
                        "isMultipleSelection" to isMultipleSelection
                    ))
                }
                pdfFragment.addOnAnnotationDeselectedListener(listener)
                eventsMap[event] = listener
            }
            NutrientEvent.TEXT_SELECTION_CHANGED -> {
                val listener = object : TextSelectionManager.OnTextSelectionChangeListener {
                    override fun onBeforeTextSelectionChange(
                        oldSelection: TextSelection?,
                        newSelection: TextSelection?
                    ): Boolean {
                        sendEvent(event, mapOf("text" to newSelection?.text))
                        return true
                    }

                    override fun onAfterTextSelectionChange(
                        oldSelection: TextSelection?,
                        newSelection: TextSelection?
                    ) {
                        sendEvent(event, mapOf("text" to newSelection?.text))
                    }
                }
                pdfFragment.addOnTextSelectionChangeListener(listener)
                eventsMap[event] = listener
            }
            NutrientEvent.FORM_FIELD_VALUES_UPDATED -> {
                val listener = FormManager.OnFormElementUpdatedListener { formElement ->
                    sendEvent(event, mapOf(
                        "formElement" to formElement.fullyQualifiedName,
                        "annotation" to formElement.annotation.toInstantJson()
                    ))
                }
                pdfFragment.addOnFormElementUpdatedListener(listener)
                eventsMap[event] = listener
            }
            NutrientEvent.FORM_FIELD_SELECTED -> {
                val listener = FormManager.OnFormElementSelectedListener { formElement ->
                    sendEvent(event, mapOf(
                        "formElement" to formElement.fullyQualifiedName,
                        "annotation" to formElement.annotation.toInstantJson()
                    ))
                }
                pdfFragment.addOnFormElementSelectedListener(listener)
                eventsMap[event] = listener
            }
            NutrientEvent.FORM_FIELD_DESELECTED -> {
                val listener = FormManager.OnFormElementDeselectedListener { formElement, isDeselected ->
                    sendEvent(event, mapOf(
                        "formElement" to formElement.fullyQualifiedName,
                        "isDeselected" to isDeselected,
                        "annotation" to formElement.annotation.toInstantJson()
                    ))
                }
                pdfFragment.addOnFormElementDeselectedListener(listener)
                eventsMap[event] = listener
            }
        }
    }

    /**
     * Remove an event listener for the specified event type
     * 
     * @param fragment The fragment to remove the listener from
     * @param event The event type to stop listening for
     */
    fun removeEventListener(fragment: PdfUiFragment, event: NutrientEvent) {
        val listener = eventsMap[event] ?: return
        val pdfFragment = fragment.pdfFragment ?: return

        when (event) {
            NutrientEvent.ANNOTATIONS_CREATED,
            NutrientEvent.ANNOTATIONS_DELETED,
            NutrientEvent.ANNOTATIONS_UPDATED -> {
                pdfFragment.removeOnAnnotationUpdatedListener(listener as AnnotationProvider.OnAnnotationUpdatedListener)
            }
            NutrientEvent.ANNOTATIONS_SELECTED -> {
                pdfFragment.removeOnAnnotationSelectedListener(listener as AnnotationManager.OnAnnotationSelectedListener)
            }
            NutrientEvent.ANNOTATIONS_DESELECTED -> {
                pdfFragment.removeOnAnnotationDeselectedListener(listener as AnnotationManager.OnAnnotationDeselectedListener)
            }
            NutrientEvent.TEXT_SELECTION_CHANGED -> {
                pdfFragment.removeOnTextSelectionChangeListener(listener as TextSelectionManager.OnTextSelectionChangeListener)
            }
            NutrientEvent.FORM_FIELD_VALUES_UPDATED -> {
                pdfFragment.removeOnFormElementViewUpdatedListener(listener as FormManager.OnFormElementViewUpdatedListener)
            }
            NutrientEvent.FORM_FIELD_SELECTED -> {
                pdfFragment.removeOnFormElementSelectedListener(listener as FormManager.OnFormElementSelectedListener)
            }
            NutrientEvent.FORM_FIELD_DESELECTED -> {
                pdfFragment.removeOnFormElementDeselectedListener(listener as FormManager.OnFormElementDeselectedListener)
            }
        }
        eventsMap.remove(event)
    }

    /**
     * Helper method to create an annotation listener with specific callbacks
     */
    private fun createAnnotationListener(
        pdfFragment: com.pspdfkit.ui.PdfFragment,
        event: NutrientEvent,
        onCreated: ((Annotation) -> Unit)? = null,
        onUpdated: ((Annotation) -> Unit)? = null,
        onRemoved: ((Annotation) -> Unit)? = null
    ) {
        val listener = object : AnnotationProvider.OnAnnotationUpdatedListener {
            override fun onAnnotationCreated(annotation: Annotation) {
                onCreated?.invoke(annotation)
            }

            override fun onAnnotationUpdated(annotation: Annotation) {
                onUpdated?.invoke(annotation)
            }

            override fun onAnnotationRemoved(annotation: Annotation) {
                onRemoved?.invoke(annotation)
            }

            override fun onAnnotationZOrderChanged(
                pageIndex: Int,
                annotations: MutableList<Annotation>,
                annotations2: MutableList<Annotation>
            ) {
                // Not used in current implementation
            }
        }
        pdfFragment.addOnAnnotationUpdatedListener(listener)
        eventsMap[event] = listener
    }

    /**
     * Helper method to send events to Flutter
     */
    private fun sendEvent(event: NutrientEvent, data: Any) {
        eventCallbacks?.onEvent(event, data) { }
    }
}
