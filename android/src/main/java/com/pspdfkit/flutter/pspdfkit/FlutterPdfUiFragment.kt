package com.pspdfkit.flutter.pspdfkit

import com.pspdfkit.annotations.measurements.FloatPrecision
import com.pspdfkit.annotations.measurements.Scale
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.ui.PdfUiFragment

class FlutterPdfUiFragment : PdfUiFragment() {

    private var scale: Scale? = null
    private var precision: FloatPrecision? = null

    override fun onDocumentLoaded(document: PdfDocument) {
        super.onDocumentLoaded(document)
      // Notify the Flutter PSPDFKit plugin that the document has been loaded.
        EventDispatcher.getInstance().notifyDocumentLoaded(document)
        // We can register interest in newly created annotations so we can easily pick up measurement information.
        if (scale != null) {
            document.measurementScale = scale
        }
        if (precision != null) {
            document.measurementPrecision = precision
        }
    }

    fun setMeasurementScale(scale: Scale?) {
        this.scale = scale
    }

    fun setMeasurementPrecision(precision: FloatPrecision?) {
        this.precision = precision
    }

}