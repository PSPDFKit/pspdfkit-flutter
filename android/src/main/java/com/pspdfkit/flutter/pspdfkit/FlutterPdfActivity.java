/*
 * Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.pspdfkit.document.PdfDocument;
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper;
import com.pspdfkit.ui.PdfActivity;
import com.pspdfkit.ui.toolbar.AnnotationToolbar;
import com.pspdfkit.ui.toolbar.ContextualToolbar;
import com.pspdfkit.ui.toolbar.ToolbarCoordinatorLayout;

import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * For communication with the PSPDFKit plugin, we keep a static reference to the current
 * activity.
 */
public class FlutterPdfActivity extends PdfActivity
        implements ToolbarCoordinatorLayout.OnContextualToolbarLifecycleListener {

    /**
     * Intent extra carrying the stylus button visibility. Passed per intent rather than through a
     * static so back-to-back present() calls can't race each other.
     */
    public static final String EXTRA_SHOW_STYLUS_BUTTON =
            "com.pspdfkit.flutter.SHOW_STYLUS_BUTTON";

    @Nullable private static FlutterPdfActivity currentActivity;
    @NonNull private static final AtomicReference<Result> loadedDocumentResult = new AtomicReference<>();

    @Nullable private  static List<Map<String,Object>> measurementValueConfigurations;

    private boolean showStylusButton = true;

    public static void setLoadedDocumentResult(Result result) {
        loadedDocumentResult.set(result);
    }

    public static void setMeasurementValueConfigurations(@Nullable final List<Map<String,Object>> configurations) {
        measurementValueConfigurations = configurations;
    }

    @Override
    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        if (getIntent() != null) {
            showStylusButton = getIntent().getBooleanExtra(EXTRA_SHOW_STYLUS_BUTTON, true);
        }
        // The stylus button isn't a PdfActivityConfiguration property, so it has to be applied on
        // the live AnnotationToolbar each time one is prepared.
        setOnContextualToolbarLifecycleListener(this);
        bindActivity();
    }

    @Override
    public void onPrepareContextualToolbar(@NonNull ContextualToolbar toolbar) {
        if (toolbar instanceof AnnotationToolbar) {
            ((AnnotationToolbar) toolbar).setShouldShowStylusButton(showStylusButton);
        }
    }

    @Override
    public void onDisplayContextualToolbar(@NonNull ContextualToolbar toolbar) {
        // No-op, required by OnContextualToolbarLifecycleListener.
    }

    @Override
    public void onRemoveContextualToolbar(@NonNull ContextualToolbar toolbar) {
        // No-op, required by OnContextualToolbarLifecycleListener.
    }

    @Override
    public void onPause() {
        // Notify the Flutter PSPDFKit plugin that the activity is going to enter the onPause state.
        EventDispatcher.getInstance().notifyActivityOnPause();
        super.onPause();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        releaseActivity();
    }

    @Override
    public void onDocumentLoaded(@NonNull PdfDocument pdfDocument) {
        super.onDocumentLoaded(pdfDocument);
        Result result = loadedDocumentResult.getAndSet(null);
        if (result != null) {
            result.success(true);
        }
        if (measurementValueConfigurations != null && getPdfFragment() !=null) {
            for (Map<String, Object> configuration : measurementValueConfigurations) {
                MeasurementHelper.addMeasurementConfiguration(getPdfFragment(), configuration);
            }
        }
        EventDispatcher.getInstance().notifyDocumentLoaded(pdfDocument);
    }

    @Override
    public void onAttachFragment(@NonNull Fragment fragment) {
        super.onAttachFragment(fragment);
        if(fragment.getTag() !=null && fragment.getTag().contains("Nutrient.Fragment")){
            EventDispatcher.getInstance().notifyPdfFragmentAdded();
        }
    }

    @Override
    public void onDocumentLoadFailed(@NonNull Throwable throwable) {
        super.onDocumentLoadFailed(throwable);
        Result result = loadedDocumentResult.getAndSet(null);
        if (result != null) {
            result.success(false);
        }
    }

    private void bindActivity() {
        currentActivity = this;
    }

    private void releaseActivity() {
        Result result = loadedDocumentResult.getAndSet(null);
        if (result != null) {
            result.success(false);
        }
        currentActivity = null;
    }

    @Nullable
    public static FlutterPdfActivity getCurrentActivity() {
        return currentActivity;
    }
}
