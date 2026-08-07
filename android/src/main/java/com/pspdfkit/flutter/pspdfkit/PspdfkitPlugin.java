/*
 * Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pspdfkit.flutter.pspdfkit.api.AnalyticsEventsCallback;
import com.pspdfkit.flutter.pspdfkit.api.HeadlessDocumentApi;
import com.pspdfkit.flutter.pspdfkit.api.NutrientApi;
import com.pspdfkit.flutter.pspdfkit.api.NutrientApiCallbacks;
import com.pspdfkit.flutter.pspdfkit.document.HeadlessDocumentApiImpl;
import com.pspdfkit.flutter.pspdfkit.events.FlutterAnalyticsClient;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

/**
 * PSPDFKit plugin to load PDF and image documents.
 *
 * <p>Communication with Flutter is handled through the Pigeon-generated {@link NutrientApi} and
 * {@link HeadlessDocumentApi}; the PDF view exposes its own per-instance API (see
 * {@code PSPDFKitView}). The legacy {@code com.nutrient.global} MethodChannel has been removed.
 */
public class PspdfkitPlugin
        implements
        FlutterPlugin,
        ActivityAware {
    @NonNull
    private static final EventDispatcher eventDispatcher = EventDispatcher.getInstance();
    private static final String MESSAGE_CHANNEL_SUFFIX = "nutrient";

    @Nullable
    private ActivityPluginBinding activityPluginBinding;

    private final PspdfkitApiImpl pspdfkitApi = new PspdfkitApiImpl(null);

    @Nullable
    private HeadlessDocumentApiImpl headlessDocumentApi;

    /**
     * This {@code FlutterPlugin} has been associated with a {@link FlutterEngine} instance.
     *
     * <p>Relevant resources that this {@code FlutterPlugin} may need are provided via the {@code
     * binding}. The {@code binding} may be cached and referenced until {@link
     * #onDetachedFromEngine(FlutterPluginBinding)} is invoked and returns.
     */
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        // Register the view factory for the PSPDFKit widget provided by `PSPDFKitViewFactory`.
        binding
                .getPlatformViewRegistry()
                .registerViewFactory(
                        "com.nutrient.widget",
                        new PSPDFKitViewFactory(binding.getBinaryMessenger())
                );
        // Setup the PSPDFKit API.
        NutrientApi.Companion.setUp(binding.getBinaryMessenger(), pspdfkitApi, MESSAGE_CHANNEL_SUFFIX);
        NutrientApiCallbacks pspdfkitFlutterApiCallbacks = new NutrientApiCallbacks(binding.getBinaryMessenger(), MESSAGE_CHANNEL_SUFFIX);
        AnalyticsEventsCallback callback = new AnalyticsEventsCallback(binding.getBinaryMessenger(), MESSAGE_CHANNEL_SUFFIX);
        pspdfkitApi.setAnalyticsEventClient(new FlutterAnalyticsClient(callback));
        eventDispatcher.setPspdfkitApiCallbacks(new PspdfkitApiCallbacks(pspdfkitFlutterApiCallbacks));

        // Setup the HeadlessDocumentApi - requires application context
        headlessDocumentApi = new HeadlessDocumentApiImpl(
                binding.getApplicationContext(),
                binding.getBinaryMessenger()
        );
        HeadlessDocumentApi.Companion.setUp(binding.getBinaryMessenger(), headlessDocumentApi, MESSAGE_CHANNEL_SUFFIX);
    }

    /**
     * This {@code FlutterPlugin} has been removed from a {@link FlutterEngine} instance.
     *
     * <p>The {@code binding} passed to this method is the same instance that was passed in {@link
     * #onAttachedToEngine(FlutterPluginBinding)}. It is provided again in this method as a
     * convenience. The {@code binding} may be referenced during the execution of this method, but it
     * must not be cached or referenced after this method returns.
     *
     * <p>{@code FlutterPlugin}s should release all resources in this method.
     */
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        eventDispatcher.setPspdfkitApiCallbacks(null);
        NutrientApi.Companion.setUp(binding.getBinaryMessenger(), null, MESSAGE_CHANNEL_SUFFIX);
        pspdfkitApi.dispose();

        // Cleanup HeadlessDocumentApi
        if (headlessDocumentApi != null) {
            headlessDocumentApi.dispose();
            HeadlessDocumentApi.Companion.setUp(binding.getBinaryMessenger(), null, MESSAGE_CHANNEL_SUFFIX);
            headlessDocumentApi = null;
        }
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityPluginBinding = binding;
        pspdfkitApi.setActivityPluginBinding(activityPluginBinding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        detachActivityPluginBinding();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(
            @NonNull ActivityPluginBinding binding
    ) {
        activityPluginBinding = binding;
        pspdfkitApi.setActivityPluginBinding(activityPluginBinding);
    }

    @Override
    public void onDetachedFromActivity() {
        detachActivityPluginBinding();
    }

    private void detachActivityPluginBinding() {
        if (activityPluginBinding != null) {
            activityPluginBinding = null;
            pspdfkitApi.setActivityPluginBinding(null);
        }
    }
}
