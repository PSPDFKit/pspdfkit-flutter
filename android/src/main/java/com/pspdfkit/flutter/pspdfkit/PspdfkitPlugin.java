/*
 * Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit;

import android.app.Activity;
import android.app.Application;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.FragmentActivity;

import com.pspdfkit.document.PdfDocument;
import com.pspdfkit.flutter.pspdfkit.api.AnalyticsEventsCallback;
import com.pspdfkit.flutter.pspdfkit.api.NutrientApi;
import com.pspdfkit.flutter.pspdfkit.api.NutrientApiCallbacks;
import com.pspdfkit.flutter.pspdfkit.events.FlutterAnalyticsClient;
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper;
import com.pspdfkit.listeners.SimpleDocumentListener;
import com.pspdfkit.ui.PdfFragment;

import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * PSPDFKit plugin to load PDF and image documents.
 */
public class PspdfkitPlugin
        implements
        PluginRegistry.RequestPermissionsResultListener,
        FlutterPlugin,
        ActivityAware, Application.ActivityLifecycleCallbacks {
    @NonNull
    private static final EventDispatcher eventDispatcher = EventDispatcher.getInstance();
    private static final String LOG_TAG = "PSPDFKitPlugin";
    private static final String MESSAGE_CHANNEL_SUFFIX = "nutrient";

    @Nullable
    private ActivityPluginBinding activityPluginBinding;

    private final PspdfkitApiImpl pspdfkitApi = new PspdfkitApiImpl(null);


    private PspdfkitPluginMethodCallHandler methodCallHandler;

    private MethodChannel channel;

    /**
     * This {@code FlutterPlugin} has been associated with a {@link FlutterEngine} instance.
     *
     * <p>Relevant resources that this {@code FlutterPlugin} may need are provided via the {@code
     * binding}. The {@code binding} may be cached and referenced until {@link
     * #onDetachedFromEngine(FlutterPluginBinding)} is invoked and returns.
     */
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(
                binding.getBinaryMessenger(),
                "com.nutrient.global"
        );
        eventDispatcher.setChannel(channel);
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
        eventDispatcher.setChannel(null);
        if (methodCallHandler != null) {
            methodCallHandler.dispose();
        }
        NutrientApi.Companion.setUp(binding.getBinaryMessenger(), null, MESSAGE_CHANNEL_SUFFIX);
        pspdfkitApi.dispose();
    }

    @Override
    public boolean onRequestPermissionsResult(
            int requestCode,
            @NonNull String[] permissions,
            @NonNull int[] grantResults
    ) {
        if (activityPluginBinding == null) {
            throw new IllegalStateException(
                    "There is no activity attached. Make sure " +
                            "`onAttachedToActivity` is called before handling any method calls received " +
                            "from Flutter"
            );
        }

        final FragmentActivity activity = (FragmentActivity) activityPluginBinding.getActivity();

        if (permissions.length == 0) return false;

        int status = 0;
        String permission = permissions[0];
        if (requestCode == 0 && grantResults.length > 0) {
            if (
                    ActivityCompat.shouldShowRequestPermissionRationale(
                            activity,
                            permission
                    )
            ) {
                // Permission denied.
                status = 1;
            } else {
                if (
                        ActivityCompat.checkSelfPermission(activity, permission) ==
                                PackageManager.PERMISSION_GRANTED
                ) {
                    // Permission allowed.
                    status = 2;
                } else {
                    // Set to never ask again.
                    Log.i(LOG_TAG, "Set to never ask again " + permission);
                    status = 3;
                }
            }
        }
        Log.i(LOG_TAG, "Requesting permission status: " + status);
        Result result = methodCallHandler.getPermissionRequestResult().getAndSet(null);
        if (result != null) {
            result.success(status);
        }
        return status == 2;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityPluginBinding = binding;
        binding.addRequestPermissionsResultListener(this);
        methodCallHandler = new PspdfkitPluginMethodCallHandler(binding.getActivity(), this);
        channel.setMethodCallHandler(methodCallHandler);
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
        binding.addRequestPermissionsResultListener(this);
        pspdfkitApi.setActivityPluginBinding(activityPluginBinding);
    }

    @Override
    public void onDetachedFromActivity() {
        detachActivityPluginBinding();
    }

    private void detachActivityPluginBinding() {
        if (activityPluginBinding != null) {
            activityPluginBinding.removeRequestPermissionsResultListener(this);
            activityPluginBinding = null;
            pspdfkitApi.setActivityPluginBinding(null);

        }
    }

    @Override
    public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {

    }

    @Override
    public void onActivityStarted(@NonNull Activity activity) {

    }

    @Override
    public void onActivityResumed(@NonNull Activity activity) {
        if (activity instanceof FlutterPdfActivity) {
            PdfFragment pdfFragment = ((FlutterPdfActivity) activity).getPdfFragment();
            if (pdfFragment == null) {
                return;
            }
            methodCallHandler.setPdfFragment(pdfFragment);
            pdfFragment.addDocumentListener(new SimpleDocumentListener() {
                @Override
                public void onDocumentLoaded(@NonNull PdfDocument document) {
                    super.onDocumentLoaded(document);
                    if (methodCallHandler.getMeasurementValueConfigurations() != null) {
                        for (Map<String, Object> configuration : methodCallHandler.getMeasurementValueConfigurations()) {
                            MeasurementHelper.addMeasurementConfiguration(pdfFragment, configuration);
                        }
                    }
                }
            });
        }
    }

    @Override
    public void onActivityPaused(@NonNull Activity activity) {

    }

    @Override
    public void onActivityStopped(@NonNull Activity activity) {

    }

    @Override
    public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {

    }

    @Override
    public void onActivityDestroyed(@NonNull Activity activity) {

    }
}
