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
    private val methodChannel: MethodChannel, private val measurementConfigurations:
    List<Map<String, Any>>?,
    private val binaryMessenger: BinaryMessenger,
    private val flutterWidgetCallback: FlutterWidgetCallback
) : FragmentManager.FragmentLifecycleCallbacks(), DocumentListener {

    private var pdfFragment: PdfFragment? = null
    private var flutterPdfDocument: FlutterPdfDocument? = null

    override fun onFragmentAttached(
        fm: FragmentManager,
        f: Fragment,
        context: Context
    ) {
        if (f.tag?.contains("PSPDFKit.Fragment") == true) {
            EventDispatcher.getInstance().notifyPdfFragmentAdded()
            if (f !is PdfFragment) {
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
        measurementConfigurations?.forEach {
            MeasurementHelper.addMeasurementConfiguration(pdfFragment!!, it)
        }
        methodChannel.invokeMethod(
            "onDocumentLoaded", mapOf(
                "documentId" to document.uid
            )
        )
        flutterWidgetCallback.onDocumentLoaded(document)
        flutterPdfDocument =
            FlutterPdfDocument(document);
        PdfDocumentApi.setUp(binaryMessenger, flutterPdfDocument, document.uid)
    }

    override fun onPageChanged(document: PdfDocument, pageIndex: Int) {
        super.onPageChanged(document, pageIndex)
        flutterWidgetCallback.onPageChanged(document, pageIndex)
        methodChannel.invokeMethod(
            "onPageChanged",
            mapOf(
                "documentId" to document.uid,
                "pageIndex" to pageIndex
            )
        )
    }

    override fun onDocumentLoadFailed(exception: Throwable) {
        super.onDocumentLoadFailed(exception)
        flutterWidgetCallback.onDocumentLoadFailed(exception)
        methodChannel.invokeMethod(
            "onDocumentLoadFailed",
            mapOf(
                "error" to exception.message
            )
        )
    }

    override fun onFragmentDetached(fm: FragmentManager, f: Fragment) {
        if (f.tag?.contains("PSPDFKit.Fragment") == true) {
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
        flutterWidgetCallback.onPageClick(document, pageIndex, event, pagePosition, clickedAnnotation)
        return true
    }

    override fun onDocumentSave(document: PdfDocument, saveOptions: DocumentSaveOptions): Boolean {
        flutterWidgetCallback.onDocumentSave(document,saveOptions)
        return true
    }
}