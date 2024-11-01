/*
 * Copyright © 2024 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit

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
}