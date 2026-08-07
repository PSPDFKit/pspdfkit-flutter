/*
 * Copyright © 2021-2026 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit

import android.graphics.RectF
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import com.pspdfkit.ai.createAiAssistantForInstant
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.ai.FlutterAiAssistantRegistry
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper
import com.pspdfkit.instant.document.InstantPdfDocument
import com.pspdfkit.instant.exceptions.InstantException
import com.pspdfkit.instant.ui.InstantPdfActivity
import com.pspdfkit.ui.toolbar.AnnotationToolbar
import com.pspdfkit.ui.toolbar.ContextualToolbar
import com.pspdfkit.ui.toolbar.ToolbarCoordinatorLayout
import io.flutter.plugin.common.MethodChannel
import io.nutrient.domain.ai.AiAssistant
import io.nutrient.domain.ai.AiAssistantProvider
import java.util.concurrent.atomic.AtomicReference

// Activities don't have a meaningful "view id" the way platform views do. We
// pick a sentinel that won't collide with real Flutter platform view ids
// (those start at 0 and grow positive).
private const val INSTANT_ACTIVITY_VIEW_ID = -1

/**
 * For communication with the PSPDFKit plugin, we keep a static reference to the current
 * activity.
 */
class FlutterInstantPdfActivity :
    InstantPdfActivity(),
    AiAssistantProvider,
    ToolbarCoordinatorLayout.OnContextualToolbarLifecycleListener {

    private var showStylusButton: Boolean = true

    override fun getAiAssistant(): AiAssistant? =
        FlutterAiAssistantRegistry.get(INSTANT_ACTIVITY_VIEW_ID)
            ?: FlutterAiAssistantRegistry.getActive()

    override fun navigateTo(documentRect: List<RectF>, pageIndex: Int, documentIndex: Int) {
        try {
            pdfFragment?.let { fragment ->
                fragment.setPageIndex(pageIndex, true)
                fragment.highlight(this, documentRect, pageIndex)
            }
        } catch (t: Throwable) {
            Log.e(LOG_TAG, "AI Assistant navigateTo failed", t)
        }
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        showStylusButton = intent.getBooleanExtra(EXTRA_SHOW_STYLUS_BUTTON, true)
        // The stylus button isn't a PdfActivityConfiguration property, so it has
        // to be applied on the live AnnotationToolbar each time one is prepared.
        setOnContextualToolbarLifecycleListener(this)
        bindActivity()
    }

    override fun onPrepareContextualToolbar(toolbar: ContextualToolbar<*>) {
        if (toolbar is AnnotationToolbar) {
            toolbar.setShouldShowStylusButton(showStylusButton)
        }
    }

    override fun onDisplayContextualToolbar(toolbar: ContextualToolbar<*>) {
        // No-op, required by OnContextualToolbarLifecycleListener.
    }

    override fun onRemoveContextualToolbar(toolbar: ContextualToolbar<*>) {
        // No-op, required by OnContextualToolbarLifecycleListener.
    }

    override fun onPause() {
        // Notify the Flutter PSPDFKit plugin that the activity is going to enter the onPause state.
        EventDispatcher.getInstance().notifyActivityOnPause()
        super.onPause()
    }

    override fun onDestroy() {
        super.onDestroy()
        releaseActivity()
        // Release the AI Assistant socket so it doesn't outlive the activity.
        FlutterAiAssistantRegistry.unregister(INSTANT_ACTIVITY_VIEW_ID)
        // No static state to clear — config now lives in this activity's
        // Intent extras and is garbage-collected with the activity instance.
    }
    
    override fun onDocumentLoaded(pdfDocument: PdfDocument) {
        super.onDocumentLoaded(pdfDocument)
        val result = loadedDocumentResult.getAndSet(null)
        result?.success(true)
        measurementValueConfigurations?.forEach {
            pdfFragment.let { fragment ->
                MeasurementHelper.addMeasurementConfiguration(fragment, it)
            }
        }
        setupAiAssistantForInstant(pdfDocument)
    }

    private fun setupAiAssistantForInstant(pdfDocument: PdfDocument) {
        val aiServerUrl = intent.getStringExtra(EXTRA_AI_SERVER_URL) ?: return
        val aiJwt = intent.getStringExtra(EXTRA_AI_JWT) ?: return
        val sessionId = intent.getStringExtra(EXTRA_AI_SESSION_ID) ?: return
        val instantServerUrl = intent.getStringExtra(EXTRA_INSTANT_SERVER_URL) ?: run {
            Log.e(LOG_TAG, "AI Assistant: missing Instant server URL in Intent extras")
            return
        }
        val instantDoc = pdfDocument as? InstantPdfDocument ?: run {
            Log.w(LOG_TAG, "AI Assistant: expected InstantPdfDocument, got ${pdfDocument::class.java.simpleName}")
            return
        }
        val layerJwt = instantDoc.instantDocumentDescriptor.jwt
        if (layerJwt == null) {
            Log.e(LOG_TAG, "AI Assistant: missing Instant layer JWT")
            return
        }
        try {
            val assistant = createAiAssistantForInstant(
                context = this,
                instantServerUrl = instantServerUrl,
                documentLayerJwts = listOf(layerJwt),
                aiAssistantServerUrl = aiServerUrl,
                sessionId = sessionId,
                jwtToken = { _ -> aiJwt }
            )
            FlutterAiAssistantRegistry.register(INSTANT_ACTIVITY_VIEW_ID, assistant)
            Log.d(LOG_TAG, "AI Assistant (Instant) created for document ${instantDoc.uid}")
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error creating AI Assistant for Instant document", e)
        }
    }

    override fun onDocumentLoadFailed(throwable: Throwable) {
        super.onDocumentLoadFailed(throwable)
        val result = loadedDocumentResult.getAndSet(null)
        result?.success(false)
    }
    
    override fun onSyncStarted(instantDocument: InstantPdfDocument) {
        super.onSyncStarted(instantDocument)
        EventDispatcher.getInstance()
            .notifyInstantSyncStarted(instantDocument.instantDocumentDescriptor.documentId)
    }

    override fun onSyncFinished(instantDocument: InstantPdfDocument) {
        super.onSyncFinished(instantDocument)
        EventDispatcher.getInstance()
            .notifyInstantSyncFinished(instantDocument.instantDocumentDescriptor.documentId)
    }

    override fun onSyncError(instantDocument: InstantPdfDocument, error: InstantException) {
        super.onSyncError(instantDocument, error)
        EventDispatcher.getInstance().notifyInstantSyncFailed(
            instantDocument.instantDocumentDescriptor.documentId,
            error.message
        )
    }

    override fun onAuthenticationFinished(instantDocument: InstantPdfDocument, validJwt: String) {
        super.onAuthenticationFinished(instantDocument, validJwt)
        EventDispatcher.getInstance().notifyInstantAuthenticationFinished(
            instantDocument.instantDocumentDescriptor.documentId,
            validJwt
        )
    }

    override fun onAuthenticationFailed(
        instantDocument: InstantPdfDocument,
        error: InstantException
    ) {
        super.onAuthenticationFailed(instantDocument, error)
        EventDispatcher.getInstance().notifyInstantAuthenticationFailed(
            instantDocument.instantDocumentDescriptor.documentId,
            error.message
        )
    }

    override fun onAttachFragment(fragment: Fragment) {
        super.onAttachFragment(fragment)
        if(fragment.tag?.contains("Nutrient.Fragment") == true){
            EventDispatcher.getInstance().notifyPdfFragmentAdded()
        }
    }

    private fun bindActivity() {
        currentActivity = this
    }

    private fun releaseActivity() {
        val result = loadedDocumentResult.getAndSet(null)
        result?.success(false)
        currentActivity = null
    }

    companion object {
        private const val LOG_TAG = "PSPDFKitPlugin"
        private  var measurementValueConfigurations:List<Map<String,Any>>? = null

        // Intent extras: each FlutterInstantPdfActivity instance owns its own
        // AI Assistant configuration via these keys, so a rapid sequence of
        // presentInstant() calls can no longer race on a shared static slot.
        // See PR #53248 review comment on the static-config race.
        const val EXTRA_AI_SERVER_URL = "com.pspdfkit.flutter.AI_SERVER_URL"
        const val EXTRA_AI_JWT = "com.pspdfkit.flutter.AI_JWT"
        const val EXTRA_AI_SESSION_ID = "com.pspdfkit.flutter.AI_SESSION_ID"
        const val EXTRA_INSTANT_SERVER_URL = "com.pspdfkit.flutter.INSTANT_SERVER_URL"

        /** Carries the stylus button visibility, per intent for the same reason. */
        const val EXTRA_SHOW_STYLUS_BUTTON = "com.pspdfkit.flutter.SHOW_STYLUS_BUTTON"

        @JvmStatic
        var currentActivity: FlutterInstantPdfActivity? = null
            private set
        private val loadedDocumentResult = AtomicReference<MethodChannel.Result?>()


        @JvmStatic
        fun setLoadedDocumentResult(result: MethodChannel.Result?) {
            loadedDocumentResult.set(result)
        }

        @JvmStatic
        fun setMeasurementValueConfigurations(configurations: List<Map<String, Any>>?) {
            measurementValueConfigurations = configurations
        }
    }
}