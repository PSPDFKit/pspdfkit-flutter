package com.pspdfkit.flutter.pspdfkit.events

import android.util.Log
import com.pspdfkit.annotations.Annotation
import com.pspdfkit.annotations.AnnotationProvider
import com.pspdfkit.datastructures.TextSelection
import com.pspdfkit.flutter.pspdfkit.annotations.AnnotationMenuHandler
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
class FlutterEventsHelper(
    private val eventCallbacks: NutrientEventsCallbacks? = null,
    private val annotationMenuHandler: AnnotationMenuHandler? = null
) {

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
                val listener = object : com.pspdfkit.ui.annotations.OnAnnotationSelectedListener{
                    override fun onPrepareAnnotationSelection(
                        controller: AnnotationSelectionController,
                        annotation: Annotation,
                        isMultipleSelection: Boolean
                    ): Boolean = true

                    override fun onAnnotationSelected(
                        annotation: Annotation,
                        isMultipleSelection: Boolean
                    ) {
                        // Notify annotation menu handler of selection
                        annotationMenuHandler?.onAnnotationSelected(annotation, isMultipleSelection)
                        
                        sendEvent(event, mapOf(
                            "annotation" to annotation.toInstantJson(),
                            "isMultipleSelection" to isMultipleSelection
                        ))
                    }

                    override fun onAnnotationDeselected(
                        annotation: Annotation?,
                        reselected: Boolean
                    ) {
                        super.onAnnotationDeselected(annotation, reselected)
                    }
                }
                pdfFragment.addOnAnnotationSelectedListener(listener)
                eventsMap[event] = listener
            }
            NutrientEvent.ANNOTATIONS_DESELECTED -> {
                val listener = object : com.pspdfkit.ui.annotations.OnAnnotationSelectedListener{
                    override fun onPrepareAnnotationSelection(
                        controller: AnnotationSelectionController,
                        annotation: Annotation,
                        isMultipleSelection: Boolean
                    ): Boolean = true

                    override fun onAnnotationSelected(
                        annotation: Annotation,
                        isMultipleSelection: Boolean
                    ) {

                    }

                    override fun onAnnotationDeselected(
                        annotation: Annotation?,
                        reselected: Boolean
                    ) {
                        super.onAnnotationDeselected(annotation, reselected)
                        // Clear selected annotation from handler when deselected
                        annotationMenuHandler?.clearSelectedAnnotation()
                        
                        if (annotation != null) {
                            sendEvent(event, mapOf(
                                "deselected" to mapOf(
                                    "name" to annotation.name,
                                    "type" to annotation.type.name,
                                    "id" to annotation.uuid,
                                    "objectNumber" to annotation.objectNumber,
                                    "reselected" to reselected
                                ),
                            ))
                        }
                    }
                }
                pdfFragment.addOnAnnotationSelectedListener(listener)
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
    fun removeEventListener(fragment: PdfUiFragment?, event: NutrientEvent?) {
        // Defensive null checks
        if (fragment == null || event == null) {
            return
        }
        
        val listener = eventsMap[event] ?: return
        val pdfFragment = fragment.pdfFragment ?: return

        try {
            when (event) {
                NutrientEvent.ANNOTATIONS_CREATED,
                NutrientEvent.ANNOTATIONS_DELETED,
                NutrientEvent.ANNOTATIONS_UPDATED -> {
                    if (listener is AnnotationProvider.OnAnnotationUpdatedListener) {
                        pdfFragment.removeOnAnnotationUpdatedListener(listener)
                    }
                }
                NutrientEvent.ANNOTATIONS_SELECTED -> {
                    if (listener is com.pspdfkit.ui.annotations.OnAnnotationSelectedListener) {
                        pdfFragment.removeOnAnnotationSelectedListener(listener)
                    }
                }
                NutrientEvent.ANNOTATIONS_DESELECTED -> {
                    if (listener is com.pspdfkit.ui.annotations.OnAnnotationSelectedListener) {
                        pdfFragment.removeOnAnnotationSelectedListener(listener)
                    }
                }
                NutrientEvent.TEXT_SELECTION_CHANGED -> {
                    if (listener is TextSelectionManager.OnTextSelectionChangeListener) {
                        pdfFragment.removeOnTextSelectionChangeListener(listener)
                    }
                }
                NutrientEvent.FORM_FIELD_VALUES_UPDATED -> {
                    if (listener is FormManager.OnFormElementUpdatedListener) {
                        pdfFragment.removeOnFormElementUpdatedListener(listener)
                    }
                }
                NutrientEvent.FORM_FIELD_SELECTED -> {
                    if (listener is FormManager.OnFormElementSelectedListener) {
                        pdfFragment.removeOnFormElementSelectedListener(listener)
                    }
                }
                NutrientEvent.FORM_FIELD_DESELECTED -> {
                    if (listener is FormManager.OnFormElementDeselectedListener) {
                        pdfFragment.removeOnFormElementDeselectedListener(listener)
                    }
                }
            }
        } catch (e: Exception) {
            // Log the error but don't throw - we want to continue with cleanup
            android.util.Log.w("FlutterEventsHelper", "Error removing event listener for $event", e)
        } finally {
            // Always remove from map regardless of whether removal succeeded
            eventsMap.remove(event)
        }
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
     * Remove all registered event listeners and clean up resources
     * 
     * @param fragment The fragment to remove all listeners from
     */
    fun removeAllEventListeners(fragment: PdfUiFragment?) {
        // Defensive null check
        if (fragment == null) {
            // Still clear the map to prevent memory leaks
            eventsMap.clear()
            return
        }
        
        // Create a copy of the events map to avoid concurrent modification
        val eventsToRemove = eventsMap.keys.toList()
        
        // Remove each event listener
        for (event in eventsToRemove) {
            removeEventListener(fragment, event)
        }
        
        // Ensure map is completely cleared
        eventsMap.clear()
    }
    
    /**
     * Check if there are any registered event listeners
     * 
     * @return true if there are registered listeners, false otherwise
     */
    fun hasRegisteredListeners(): Boolean {
        return eventsMap.isNotEmpty()
    }
    
    /**
     * Get the count of registered event listeners
     * 
     * @return the number of registered listeners
     */
    fun getRegisteredListenersCount(): Int {
        return eventsMap.size
    }

    /**
     * Helper method to send events to Flutter
     */
    private fun sendEvent(event: NutrientEvent, data: Any) {
        try {
            eventCallbacks?.onEvent(event, data) { }
        } catch (e: Exception) {
            // Log the error but don't throw - we don't want event sending to crash the app
            android.util.Log.w("FlutterEventsHelper", "Error sending event $event", e)
        }
    }
}
