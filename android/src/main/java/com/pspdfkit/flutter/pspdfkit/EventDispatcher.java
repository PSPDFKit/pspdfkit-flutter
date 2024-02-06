///
///  Copyright © 2021-2024 PSPDFKit GmbH. All rights reserved.
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

import java.util.HashMap;

import io.flutter.plugin.common.MethodChannel;

/**
 * Internal singleton class used to communicate between activities and the PSPDFKit Flutter plugin.
 */
public class EventDispatcher {
    @Nullable
    private static EventDispatcher instance;
    /**
     * A channel for sending events from Java to Flutter. This is set as soon as
     * the plugin is registered.
     */
    @Nullable
    private MethodChannel channel = null;

    private EventDispatcher() {
    }

    @NonNull
    public static synchronized EventDispatcher getInstance() {
        if (instance == null) {
            instance = new EventDispatcher();
        }
        return instance;
    }

    public void setChannel(@Nullable MethodChannel channel) {
        this.channel = channel;
    }

    public void notifyActivityOnPause() {
        sendEvent("flutterPdfActivityOnPause");
    }

    public void notifyPdfFragmentAdded() {
        sendEvent("flutterPdfFragmentAdded");
    }

    public void notifyInstantSyncStarted(String documentId) {
        sendEvent("pspdfkitInstantSyncStarted", documentId);
    }

    public void notifyInstantSyncFinished(String documentId) {
        sendEvent("pspdfkitInstantSyncFinished", documentId);
    }

    public void notifyInstantSyncFailed(String documentId, String error) {
        sendEvent("pspdfkitInstantSyncFailed",new HashMap<String, String>() {{
            put("documentId", documentId);
            put("error", error);
        }});
    }

    public void notifyInstantAuthenticationFinished(String documentId,String validJWT) {
        sendEvent("pspdfkitInstantAuthenticationFinished", new HashMap<String, String>() {{
            put("documentId", documentId);
            put("jwt", validJWT);
        }});
    }

    public void notifyInstantAuthenticationFailed(String documentId, String error) {
        sendEvent("pspdfkitInstantAuthenticationFailed", new HashMap<String, String>() {{
            put("documentId", documentId);
            put("error", error);
        }});
    }

    private void sendEvent(String eventName) {
        sendEvent(eventName, null);
    }

    private void sendEvent(@NonNull final String method, @Nullable final Object arguments) {
        if (channel != null) {
            channel.invokeMethod(method, arguments, null);
        }
    }

    public void notifyDocumentLoaded(@NotNull PdfDocument document) {
        sendEvent("pspdfkitDocumentLoaded", document.getUid());
    }
}
