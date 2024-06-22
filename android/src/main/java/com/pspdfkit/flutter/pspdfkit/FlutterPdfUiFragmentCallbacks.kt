package com.pspdfkit.flutter.pspdfkit

import android.content.Context
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.document.FlutterPdfDocument
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper
import com.pspdfkit.listeners.DocumentListener
import com.pspdfkit.ui.PdfFragment
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class FlutterPdfUiFragmentCallbacks(
    private val methodChannel: MethodChannel, private val measurementConfigurations:
    List<Map<String, Any>>?,
    private val binaryMessenger: BinaryMessenger
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
            pdfFragment = f as PdfFragment
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

        flutterPdfDocument =
            FlutterPdfDocument(document, binaryMessenger);
    }

    override fun onPageChanged(document: PdfDocument, pageIndex: Int) {
        super.onPageChanged(document, pageIndex)
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
}