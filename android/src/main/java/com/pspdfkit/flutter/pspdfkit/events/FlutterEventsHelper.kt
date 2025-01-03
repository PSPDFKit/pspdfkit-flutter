package com.pspdfkit.flutter.pspdfkit.events

import com.pspdfkit.annotations.Annotation
import com.pspdfkit.annotations.AnnotationProvider
import com.pspdfkit.datastructures.TextSelection
import com.pspdfkit.flutter.pspdfkit.api.NutrientEvent
import com.pspdfkit.flutter.pspdfkit.api.NutrientEventsCallbacks
import com.pspdfkit.listeners.DocumentListener
import com.pspdfkit.ui.PdfUiFragment
import com.pspdfkit.ui.special_mode.controller.AnnotationSelectionController
import com.pspdfkit.ui.special_mode.manager.AnnotationManager
import com.pspdfkit.ui.special_mode.manager.FormManager
import com.pspdfkit.ui.special_mode.manager.TextSelectionManager

class FlutterEventsHelper(val eventCallbacks: NutrientEventsCallbacks? = null) {

    private val eventsMap: MutableMap<NutrientEvent, Any> = mutableMapOf()

    fun setEventListener(pdfUiFragment: PdfUiFragment, event: NutrientEvent) {
        // Don't add duplicate listeners
        if (eventsMap.containsKey(event)) {
            return
        }

        when (event) {
            NutrientEvent.ANNOTATIONS_CREATED -> {
                val listener = object : AnnotationProvider.OnAnnotationUpdatedListener {
                    override fun onAnnotationCreated(p0: Annotation) {
                        eventCallbacks?.onEvent(
                            NutrientEvent.ANNOTATIONS_CREATED,
                            mapOf("annotation" to p0.toInstantJson()),
                        ) { }
                    }

                    override fun onAnnotationUpdated(annotation: Annotation) {
                    }

                    override fun onAnnotationRemoved(p0: Annotation) {
                    }

                    override fun onAnnotationZOrderChanged(
                        p0: Int,
                        p1: MutableList<Annotation>,
                        p2: MutableList<Annotation>
                    ) {
                    }
                }
                pdfUiFragment.pdfFragment?.addOnAnnotationUpdatedListener(listener)
                eventsMap[event] = listener
            }

            NutrientEvent.ANNOTATIONS_UPDATED -> {
                val listener = object : AnnotationProvider.OnAnnotationUpdatedListener {
                    override fun onAnnotationCreated(p0: Annotation) {}
                    override fun onAnnotationUpdated(annotation: Annotation) {
                        eventCallbacks?.onEvent(
                            NutrientEvent.ANNOTATIONS_UPDATED,
                            mapOf("annotation" to annotation.toInstantJson()),
                        ) { }
                    }

                    override fun onAnnotationRemoved(p0: Annotation) {

                    }

                    override fun onAnnotationZOrderChanged(
                        p0: Int,
                        p1: MutableList<Annotation>,
                        p2: MutableList<Annotation>
                    ) {
                    }
                }
                pdfUiFragment.pdfFragment?.addOnAnnotationUpdatedListener(listener)
                eventsMap[event] = listener
            }

            NutrientEvent.ANNOTATIONS_DELETED -> {
                val listener = object : AnnotationProvider.OnAnnotationUpdatedListener {
                    override fun onAnnotationCreated(p0: Annotation) {}
                    override fun onAnnotationUpdated(annotation: Annotation) {}
                    override fun onAnnotationRemoved(annotation: Annotation) {
                        eventCallbacks?.onEvent(
                            NutrientEvent.ANNOTATIONS_DELETED,
                            mapOf("annotation" to annotation.toInstantJson()),
                        ) { }
                    }

                    override fun onAnnotationZOrderChanged(
                        p0: Int,
                        p1: MutableList<Annotation>,
                        p2: MutableList<Annotation>
                    ) {
                    }
                }
                pdfUiFragment.pdfFragment?.addOnAnnotationUpdatedListener(listener)
                eventsMap[event] = listener
            }

            NutrientEvent.ANNOTATIONS_SELECTED -> {
                val listener = object : AnnotationManager.OnAnnotationSelectedListener {
                    override fun onPrepareAnnotationSelection(
                        controller: AnnotationSelectionController,
                        annotation: Annotation,
                        isMultipleSelection: Boolean
                    ): Boolean {
                        return true
                    }

                    override fun onAnnotationSelected(
                        annotation: Annotation,
                        isMultipleSelection: Boolean
                    ) {
                        eventCallbacks?.onEvent(
                            NutrientEvent.ANNOTATIONS_SELECTED,
                            mapOf(
                                "annotation" to annotation.toInstantJson(),
                                "isMultipleSelection" to isMultipleSelection
                            )
                        ) { }
                    }
                }
                pdfUiFragment.pdfFragment?.addOnAnnotationSelectedListener(listener)
                eventsMap[event] = listener
            }

            NutrientEvent.ANNOTATIONS_DESELECTED -> {
                val listener =
                    AnnotationManager.OnAnnotationDeselectedListener { annotation, isMultipleSelection ->
                        eventCallbacks?.onEvent(
                            NutrientEvent.ANNOTATIONS_DESELECTED,
                            mapOf(
                                "annotation" to annotation.toInstantJson(),
                                "isMultipleSelection" to isMultipleSelection
                            )
                        ) { }
                    }
                pdfUiFragment.pdfFragment?.addOnAnnotationDeselectedListener(listener)
                eventsMap[event] = listener
            }

            NutrientEvent.TEXT_SELECTION_CHANGED -> {
                val listener = object : TextSelectionManager.OnTextSelectionChangeListener {

                    override fun onBeforeTextSelectionChange(
                        p0: TextSelection?,
                        p1: TextSelection?
                    ): Boolean {
                        eventCallbacks?.onEvent(
                            event, mapOf("text" to p1?.text),
                        ) { }
                        return true
                    }

                    override fun onAfterTextSelectionChange(
                        p0: TextSelection?,
                        p1: TextSelection?
                    ) {
                        eventCallbacks?.onEvent(
                            event, mapOf("text" to p1?.text),
                        ) {

                        }
                    }
                }
                pdfUiFragment.pdfFragment?.addOnTextSelectionChangeListener(listener)
                eventsMap[event] = listener
            }

            NutrientEvent.FORM_FIELD_VALUES_UPDATED -> {
                val listener = FormManager.OnFormElementUpdatedListener {
                    eventCallbacks?.onEvent(
                        NutrientEvent.FORM_FIELD_VALUES_UPDATED,
                        mapOf(
                            "formElement" to it.fullyQualifiedName,
                            "annotation" to it.annotation.toInstantJson()
                        )
                    ) { }
                }
                pdfUiFragment.pdfFragment?.addOnFormElementUpdatedListener(listener)
                eventsMap[event] = listener
            }

            NutrientEvent.FORM_FIELD_SELECTED -> {
                val listener = FormManager.OnFormElementSelectedListener { formElement ->
                    eventCallbacks?.onEvent(
                        NutrientEvent.FORM_FIELD_SELECTED,
                        mapOf(
                            "formElement" to formElement.fullyQualifiedName,
                            "annotation" to formElement.annotation.toInstantJson()
                        )
                    ) { }
                }
                pdfUiFragment.pdfFragment?.addOnFormElementSelectedListener(listener)
                eventsMap[event] = listener
            }

            NutrientEvent.FORM_FIELD_DESELECTED -> {
                val listener =
                    FormManager.OnFormElementDeselectedListener { formElement, p1 ->
                        eventCallbacks?.onEvent(
                            NutrientEvent.FORM_FIELD_DESELECTED,
                            mapOf(
                                "formElement" to formElement.fullyQualifiedName,
                                "isDeselected" to p1,
                                "annotation" to formElement.annotation.toInstantJson()
                            )
                        ) { }
                    }
                pdfUiFragment.pdfFragment?.addOnFormElementDeselectedListener(listener)
                eventsMap[event] = listener
            }
        }
    }

    fun removeEventListener(fragment: PdfUiFragment, event: NutrientEvent) {
        val listener = eventsMap[event] ?: return
        when (event) {
            NutrientEvent.ANNOTATIONS_CREATED,
            NutrientEvent.ANNOTATIONS_DELETED,
            NutrientEvent.ANNOTATIONS_UPDATED -> {
                fragment.pdfFragment?.removeOnAnnotationUpdatedListener(listener as AnnotationProvider.OnAnnotationUpdatedListener)
            }

            NutrientEvent.ANNOTATIONS_SELECTED -> {
                fragment.pdfFragment?.removeOnAnnotationSelectedListener(listener as AnnotationManager.OnAnnotationSelectedListener)
            }

            NutrientEvent.TEXT_SELECTION_CHANGED -> {
                fragment.pdfFragment?.removeOnTextSelectionChangeListener(listener as TextSelectionManager.OnTextSelectionChangeListener)
            }

            NutrientEvent.FORM_FIELD_VALUES_UPDATED -> {
                fragment.pdfFragment?.removeOnFormElementViewUpdatedListener(listener as FormManager.OnFormElementViewUpdatedListener)
            }

            NutrientEvent.FORM_FIELD_SELECTED -> {
                fragment.pdfFragment?.removeOnFormElementSelectedListener(listener as FormManager.OnFormElementSelectedListener)
            }

            NutrientEvent.ANNOTATIONS_DESELECTED -> {
                fragment.pdfFragment?.removeOnAnnotationDeselectedListener(listener as AnnotationManager.OnAnnotationDeselectedListener)
            }

            NutrientEvent.FORM_FIELD_DESELECTED -> {
                fragment.pdfFragment?.removeOnFormElementDeselectedListener(listener as FormManager.OnFormElementDeselectedListener)
            }
        }
        eventsMap.remove(event)
    }
}
