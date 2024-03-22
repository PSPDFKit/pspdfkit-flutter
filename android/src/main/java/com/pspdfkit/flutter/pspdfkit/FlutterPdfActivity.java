package com.pspdfkit.flutter.pspdfkit;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pspdfkit.document.PdfDocument;
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper;
import com.pspdfkit.ui.PdfActivity;

import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * For communication with the PSPDFKit plugin, we keep a static reference to the current
 * activity.
 */
public class FlutterPdfActivity extends PdfActivity {

    @Nullable private static FlutterPdfActivity currentActivity;
    @NonNull private static final AtomicReference<Result> loadedDocumentResult = new AtomicReference<>();

    @Nullable private  static List<Map<String,Object>> measurementValueConfigurations;

    public static void setLoadedDocumentResult(Result result) {
        loadedDocumentResult.set(result);
    }

    public static void setMeasurementValueConfigurations(@Nullable final List<Map<String,Object>> configurations) {
        measurementValueConfigurations = configurations;
    }

    @Override
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        bindActivity();
    }

    @Override
    protected void onPause() {
        // Notify the Flutter PSPDFKit plugin that the activity is going to enter the onPause state.
        EventDispatcher.getInstance().notifyActivityOnPause();
        super.onPause();
    }

    @Override
    protected void onDestroy() {
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
