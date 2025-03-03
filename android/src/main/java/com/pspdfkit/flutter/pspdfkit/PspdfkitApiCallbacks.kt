/*
 * Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */
package com.pspdfkit.flutter.pspdfkit

import com.pspdfkit.flutter.pspdfkit.api.PspdfkitFlutterApiCallbacks

/**
 * Callbacks for the PspdfkitApi. This class is responsible for notifying the Flutter side about document loading events.
 * A separate class is used because the callback methods are not supported by Java.
 * @param pspdfkitFlutterApiCallbacks The callback to notify the Flutter side about document loading events.
 */
class PspdfkitApiCallbacks(private val pspdfkitFlutterApiCallbacks: PspdfkitFlutterApiCallbacks) {

    fun onDocumentLoaded(documentId: String) {
        pspdfkitFlutterApiCallbacks.onDocumentLoaded(documentId) {}
    }

    fun onSyncStarted(instantDocumentId: String) {
        pspdfkitFlutterApiCallbacks.onInstantSyncStarted(instantDocumentId) {}
    }

    fun onSyncFinished(instantDocumentId: String) {
        pspdfkitFlutterApiCallbacks.onInstantSyncFinished(instantDocumentId) {}
    }

    fun onAuthenticationFailed(instantDocumentId: String, error: String) {
        pspdfkitFlutterApiCallbacks.onInstantAuthenticationFailed(
            instantDocumentId,
            error
        ) {}
    }

    fun onAuthenticationFinished(instantDocumentId: String, validJwt: String) {
        pspdfkitFlutterApiCallbacks.onInstantAuthenticationFinished(
            instantDocumentId,
            validJwt
        ) {}
    }

    fun onSyncError(instantDocumentId: String, error: String) {
        pspdfkitFlutterApiCallbacks.onInstantSyncFailed(
            instantDocumentId,
            error
        ) {}
    }

    fun onFragmentAttached() {
        pspdfkitFlutterApiCallbacks.onPdfFragmentAdded {}
    }

    fun onActivityPaused() {
        pspdfkitFlutterApiCallbacks.onPdfActivityOnPause {}
    }
}