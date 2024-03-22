package com.pspdfkit.flutter.pspdfkit

///  Copyright © 2021-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import android.os.Bundle
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper
import com.pspdfkit.instant.document.InstantPdfDocument
import com.pspdfkit.instant.exceptions.InstantException
import com.pspdfkit.instant.ui.InstantPdfActivity
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicReference

/**
 * For communication with the PSPDFKit plugin, we keep a static reference to the current
 * activity.
 */
class FlutterInstantPdfActivity : InstantPdfActivity() {


    override fun onCreate(bundle: Bundle?) {
        super.onCreate(bundle)
        bindActivity()
    }

    override fun onPause() {
        // Notify the Flutter PSPDFKit plugin that the activity is going to enter the onPause state.
        EventDispatcher.getInstance().notifyActivityOnPause()
        super.onPause()
    }

    override fun onDestroy() {
        super.onDestroy()
        releaseActivity()
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

    private fun bindActivity() {
        currentActivity = this
    }

    private fun releaseActivity() {
        val result = loadedDocumentResult.getAndSet(null)
        result?.success(false)
        currentActivity = null
    }

    companion object {
        private  var measurementValueConfigurations:List<Map<String,Any>>? = null

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