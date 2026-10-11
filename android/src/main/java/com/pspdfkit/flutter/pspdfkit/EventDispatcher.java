///
///  Copyright © 2021-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

package com.pspdfkit.flutter.pspdfkit;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.pspdfkit.document.PdfDocument;
import org.jetbrains.annotations.NotNull;

/**
 * Internal singleton class used to communicate between activities and the PSPDFKit Flutter plugin.
 *
 * <p>Events are delivered to Flutter through the Pigeon-generated callbacks ({@link
 * PspdfkitApiCallbacks}). The legacy {@code com.nutrient.global} MethodChannel event path has been
 * removed.
 */
public class EventDispatcher {

    @Nullable
    private static EventDispatcher instance;

    @Nullable
    private PspdfkitApiCallbacks pspdfkitApiCallbacks;

    @NonNull
    public static synchronized EventDispatcher getInstance() {
        if (instance == null) {
            instance = new EventDispatcher();
        }
        return instance;
    }

    public void setPspdfkitApiCallbacks(@Nullable PspdfkitApiCallbacks pspdfkitApiCallbacks) {
        this.pspdfkitApiCallbacks = pspdfkitApiCallbacks;
    }

    public void notifyActivityOnPause() {
        if (pspdfkitApiCallbacks != null) {
            pspdfkitApiCallbacks.onActivityPaused();
        }
    }

    public void notifyPdfFragmentAdded() {
        if (pspdfkitApiCallbacks != null) {
            pspdfkitApiCallbacks.onFragmentAttached();
        }
    }

    public void notifyInstantSyncStarted(String documentId) {
        if (pspdfkitApiCallbacks != null) {
            pspdfkitApiCallbacks.onSyncStarted(documentId);
        }
    }

    public void notifyInstantSyncFinished(String documentId) {
        if (pspdfkitApiCallbacks != null) {
            pspdfkitApiCallbacks.onSyncFinished(documentId);
        }
    }

    public void notifyInstantSyncFailed(String documentId, String error) {
        if (pspdfkitApiCallbacks != null) {
            pspdfkitApiCallbacks.onSyncError(documentId, error);
        }
    }

    public void notifyInstantAuthenticationFinished(String documentId, String validJWT) {
        if (pspdfkitApiCallbacks != null) {
            pspdfkitApiCallbacks.onAuthenticationFinished(documentId, validJWT);
        }
    }

    public void notifyInstantAuthenticationFailed(String documentId, String error) {
        if (pspdfkitApiCallbacks != null) {
            pspdfkitApiCallbacks.onAuthenticationFailed(documentId, error);
        }
    }

    public void notifyDocumentLoaded(@NotNull PdfDocument document) {
        if (pspdfkitApiCallbacks != null) {
            pspdfkitApiCallbacks.onDocumentLoaded(document.getUid());
        }
    }
}
