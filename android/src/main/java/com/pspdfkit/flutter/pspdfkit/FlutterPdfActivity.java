package com.pspdfkit.flutter.pspdfkit;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pspdfkit.document.PdfDocument;
import com.pspdfkit.ui.PdfActivity;

import java.util.concurrent.atomic.AtomicReference;

import io.flutter.plugin.common.MethodChannel.Result;

/**
 * For communication with the PSPDFKit plugin, we keep a static reference to the current
 * activity.
 */
public class FlutterPdfActivity extends PdfActivity {

    @Nullable private static FlutterPdfActivity currentActivity;
    @NonNull private static final AtomicReference<Result> loadedDocumentResult = new AtomicReference<>();

    public static void setLoadedDocumentResult(Result result) {
        loadedDocumentResult.set(result);
    }

    @Override
    protected void onCreate(Bundle bundle) {
        EventDispatcher.getInstance().notifyActivityOnCreate();
        super.onCreate(bundle);
        bindActivity();
    }

    @Override
    protected void onStart() {
        EventDispatcher.getInstance().notifyActivityOnStart();
        super.onStart();
    }

    @Override
    protected void onPause() {
        EventDispatcher.getInstance().notifyActivityOnPause();
        super.onPause();
    }

    @Override
    protected void onResume() {
        EventDispatcher.getInstance().notifyActivityOnResume();
        super.onResume();
    }

    @Override
    protected void onStop() {
        EventDispatcher.getInstance().notifyActivityOnStop();
        super.onStop();
    }

    @Override
    protected void onRestart() {
        EventDispatcher.getInstance().notifyActivityOnRestart();
        super.onRestart();
    }

    @Override
    protected void onDestroy() {
        EventDispatcher.getInstance().notifyActivityOnDestroy();
        super.onDestroy();
        releaseActivity();
    }

    @Override
    public void onDocumentLoaded(@NonNull PdfDocument pdfDocument) {
        EventDispatcher.getInstance().notifyActivityOnDocumentLoaded();
        super.onDocumentLoaded(pdfDocument);
        Result result = loadedDocumentResult.getAndSet(null);
        if (result != null) {
            result.success(true);
        }
    }

    @Override
    public void onDocumentLoadFailed(@NonNull Throwable throwable) {
        EventDispatcher.getInstance().notifyActivityOnDocumentLoadFailed();
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
