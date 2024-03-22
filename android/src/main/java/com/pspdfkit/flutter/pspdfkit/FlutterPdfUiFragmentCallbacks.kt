package com.pspdfkit.flutter.pspdfkit

import android.content.Context
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import com.pspdfkit.annotations.measurements.MeasurementValueConfiguration
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper
import com.pspdfkit.listeners.SimpleDocumentListener
import com.pspdfkit.ui.PdfFragment

class FlutterPdfUiFragmentCallbacks(val measurementConfigurations: List<Map<String, Any>>?): FragmentManager.FragmentLifecycleCallbacks() {
    final
    override fun onFragmentAttached(
            fm: FragmentManager,
            f: Fragment,
            context: Context
    ) {
        if (f.tag?.contains("PSPDFKit.Fragment") == true) {
            EventDispatcher.getInstance().notifyPdfFragmentAdded()
            val pdfFragment = f as PdfFragment

            pdfFragment.addDocumentListener( object : SimpleDocumentListener() {
                override fun onDocumentLoaded(document: PdfDocument) {
                    if (measurementConfigurations == null) return
                    measurementConfigurations.forEach {
                        MeasurementHelper.addMeasurementConfiguration(pdfFragment, it)
                    }
                }
            })
        }
    }
}