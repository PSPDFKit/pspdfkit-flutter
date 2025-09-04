/*
 * Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */
package com.pspdfkit.flutter.pspdfkit

///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
import android.content.Context
import android.graphics.PointF
import android.util.Log
import android.view.MotionEvent
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import com.pspdfkit.annotations.Annotation
import com.pspdfkit.document.DocumentSaveOptions
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.api.PdfDocumentApi
import com.pspdfkit.flutter.pspdfkit.document.FlutterPdfDocument
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper
import com.pspdfkit.listeners.DocumentListener
import com.pspdfkit.ui.PdfFragment
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.nutrient.domain.ai.AiAssistant

private const val LOG_TAG = "FlutterPdfUiCallbacks"

/**
 * Callbacks for the FlutterPdfUiFragment.
 * This class is responsible for notifying the Flutter side about document loading events.
 * It also sets up the PdfDocumentApi for the FlutterPdfDocument.
 * @param methodChannel The method channel to communicate with the Flutter side.
 * @param measurementConfigurations The measurement configurations to apply to the PdfFragment.
 * @param binaryMessenger The binary messenger to communicate with the Flutter side.
 * @param flutterWidgetCallback The callback to notify the Flutter side about document loading events.
 */
class FlutterPdfUiFragmentCallbacks(
    private val methodChannel: MethodChannel, 
    private val measurementConfigurations: List<Map<String, Any>>?,
    private val binaryMessenger: BinaryMessenger,
    private val flutterWidgetCallback: FlutterWidgetCallback,
    private val aiAssistant: AiAssistant?

) : FragmentManager.FragmentLifecycleCallbacks(), DocumentListener {

    private var pdfFragment: PdfFragment? = null
    private var flutterPdfDocument: FlutterPdfDocument? = null

    override fun onFragmentAttached(
        fm: FragmentManager,
        f: Fragment,
        context: Context
    ) {
        if (f.tag?.contains("Nutrient.Fragment") == true) {
            EventDispatcher.getInstance().notifyPdfFragmentAdded()
            if (f !is PdfFragment) {
                Log.w(LOG_TAG, "Fragment is not a PdfFragment: ${f::class.java.simpleName}")
                return
            }
            if (pdfFragment != null) {
                return
            }
            pdfFragment = f
            pdfFragment?.addDocumentListener(this)
        }
    }

    override fun onDocumentLoaded(document: PdfDocument) {
        // Apply measurement configurations if available
        measurementConfigurations?.forEach {
            try {
                MeasurementHelper.addMeasurementConfiguration(pdfFragment!!, it)
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Failed to apply measurement configuration", e)
            }
        }

        // Set up document API for Flutter access FIRST - before sending callbacks
        try {
            flutterPdfDocument = FlutterPdfDocument(document)
            PdfDocumentApi.setUp(binaryMessenger, flutterPdfDocument, document.uid)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error setting up FlutterPdfDocument", e)
        }

        // Now send Flutter callbacks - Pigeon channels are ready
        try {
            val eventData = mapOf("documentId" to document.uid)
            methodChannel.invokeMethod("onDocumentLoaded", eventData)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error sending onDocumentLoaded via method channel", e)
        }

        // Send event through widget callbacks
        try {
            flutterWidgetCallback.onDocumentLoaded(document)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error sending onDocumentLoaded via widget callbacks", e)
        }

        // Additional direct channel sending
        try {
            EventDispatcher.getInstance().notifyDocumentLoaded(document)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error sending direct event notification", e)
        }
         aiAssistant?.let {
             try {
                 document.setAiAssistant(it)
             } catch (e: Exception) {
                 Log.e(LOG_TAG, "Error setting AiAssistant on loaded document", e)
             }
         }
    }

    override fun onPageChanged(document: PdfDocument, pageIndex: Int) {
        super.onPageChanged(document, pageIndex)
        
        try {
            flutterWidgetCallback.onPageChanged(document, pageIndex)
            methodChannel.invokeMethod(
                "onPageChanged",
                mapOf(
                    "documentId" to document.uid,
                    "pageIndex" to pageIndex
                )
            )
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error sending onPageChanged event", e)
        }
    }

    override fun onDocumentLoadFailed(exception: Throwable) {
        super.onDocumentLoadFailed(exception)
        Log.e(LOG_TAG, "Document load failed", exception)
        
        try {
            flutterWidgetCallback.onDocumentLoadFailed(exception)
            methodChannel.invokeMethod(
                "onDocumentLoadFailed",
                mapOf(
                    "error" to exception.message
                )
            )
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error sending onDocumentLoadFailed event", e)
        }
    }

    override fun onFragmentDetached(fm: FragmentManager, f: Fragment) {
        if (f.tag?.contains("Nutrient.Fragment") == true) {
            if (f !is PdfFragment) {
                return
            }
            if (pdfFragment == f) {
                pdfFragment?.removeDocumentListener(this)
                pdfFragment = null
                flutterPdfDocument = null
            }
        }
    }

    override fun onPageClick(
        document: PdfDocument,
        pageIndex: Int,
        event: MotionEvent?,
        pagePosition: PointF?,
        clickedAnnotation: Annotation?
    ): Boolean {
        try {
            flutterWidgetCallback.onPageClick(document, pageIndex, event, pagePosition, clickedAnnotation)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error sending onPageClick event", e)
        }
        return true
    }

    override fun onDocumentSave(document: PdfDocument, saveOptions: DocumentSaveOptions): Boolean {
        try {
            flutterWidgetCallback.onDocumentSave(document, saveOptions)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error sending onDocumentSave event", e)
        }
        return true
    }
}