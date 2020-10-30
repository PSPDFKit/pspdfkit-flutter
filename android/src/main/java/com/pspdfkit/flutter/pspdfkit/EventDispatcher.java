package com.pspdfkit.flutter.pspdfkit;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

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

    private void sendEvent(@NonNull final String method) {
        if (channel != null) {
            channel.invokeMethod(method, null, null);
        }
    }
}