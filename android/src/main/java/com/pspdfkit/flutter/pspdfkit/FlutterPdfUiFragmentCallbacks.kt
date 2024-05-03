package com.pspdfkit.flutter.pspdfkit

import android.content.Context
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper
import com.pspdfkit.listeners.SimpleDocumentListener
import com.pspdfkit.ui.PdfFragment
import io.flutter.plugin.common.MethodChannel

class FlutterPdfUiFragmentCallbacks(val  methodChannel: MethodChannel,val measurementConfigurations: List<Map<String, Any>>?): FragmentManager.FragmentLifecycleCallbacks() {

    var pdfFragment: PdfFragment? = null

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
            pdfFragment?.addDocumentListener( object : SimpleDocumentListener() {
                override fun onDocumentLoaded(document: PdfDocument) {
                    measurementConfigurations?.forEach {
                        MeasurementHelper.addMeasurementConfiguration(pdfFragment!!, it)
                    }
                    methodChannel.invokeMethod("onDocumentLoaded", mapOf(
                            "documentId" to document.uid
                    ))
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
            })
        }
    }
}