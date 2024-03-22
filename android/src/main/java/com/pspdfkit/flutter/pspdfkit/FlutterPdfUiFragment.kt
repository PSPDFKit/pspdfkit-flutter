package com.pspdfkit.flutter.pspdfkit

import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper
import com.pspdfkit.ui.PdfUiFragment

class FlutterPdfUiFragment : PdfUiFragment() {

    override fun onDocumentLoaded(document: PdfDocument) {
        super.onDocumentLoaded(document)
      // Notify the Flutter PSPDFKit plugin that the document has been loaded.
        EventDispatcher.getInstance().notifyDocumentLoaded(document)
    }
}