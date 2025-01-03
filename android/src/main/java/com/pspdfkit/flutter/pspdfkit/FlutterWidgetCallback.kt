/*
 * Copyright © 2024 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit

import android.graphics.PointF
import android.view.MotionEvent
import com.pspdfkit.annotations.Annotation
import com.pspdfkit.document.DocumentSaveOptions
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.api.PspdfkitWidgetCallbacks
import com.pspdfkit.listeners.DocumentListener


class FlutterWidgetCallback(
    private var pspdfkitWidgetCallbacks: PspdfkitWidgetCallbacks? = null
) : DocumentListener {

    override fun onDocumentLoaded(document: PdfDocument) {
        pspdfkitWidgetCallbacks?.onDocumentLoaded(document.uid) {}
        super.onDocumentLoaded(document)
    }

    override fun onPageChanged(document: PdfDocument, pageIndex: Int) {
        super.onPageChanged(document, pageIndex)
        pspdfkitWidgetCallbacks?.onPageChanged(document.uid, pageIndex.toLong()) {
        }
    }

    override fun onDocumentLoadFailed(exception: Throwable) {
        pspdfkitWidgetCallbacks?.onDocumentError(
            "",
            exception.localizedMessage ?: "Error while loading document!"
        ) {}
        super.onDocumentLoadFailed(exception)
    }

    override fun onPageClick(
        document: PdfDocument,
        pageIndex: Int,
        event: MotionEvent?,
        pagePosition: PointF?,
        clickedAnnotation: Annotation?
    ): Boolean {
        var flutterPointF: com.pspdfkit.flutter.pspdfkit.api.PointF? = null
        pagePosition?.let {
            flutterPointF = com.pspdfkit.flutter.pspdfkit.api.PointF(
                pagePosition.x.toDouble(),
                pagePosition.x.toDouble()
            )
        }
        pspdfkitWidgetCallbacks?.onPageClick(
            document.uid,
            pageIndex.toLong(),
            flutterPointF,
            clickedAnnotation?.toInstantJson()
        ) {}
        return true
    }

    override fun onDocumentSave(document: PdfDocument, saveOptions: DocumentSaveOptions): Boolean {
        pspdfkitWidgetCallbacks?.onDocumentSaved(
            document.uid,
            document.documentSource.fileUri?.path
        ) {}
        return true
    }
}