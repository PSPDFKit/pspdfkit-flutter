package com.pspdfkit.flutter.pspdfkit;

import android.os.Bundle;

import androidx.annotation.NonNull;

import com.pspdfkit.document.PdfDocument;
import com.pspdfkit.ui.PdfActivity;

import java.util.concurrent.atomic.AtomicReference;

import io.flutter.plugin.common.MethodChannel.Result;

/**
 * For communication with the PSPDFKit plugin, we keep a static reference to the current
 * activity.
 */
public class FlutterPdfActivity extends PdfActivity {

    private static FlutterPdfActivity currentActivity;
    private static AtomicReference<Result> loadedDocumentResult = new AtomicReference<>();

    public static void setLoadedDocumentResult(Result result) {
        loadedDocumentResult.set(result);
    }

    @Override
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        bindActivity();
    }

    @Override
    public void onDocumentLoaded(@NonNull PdfDocument pdfDocument) {
        super.onDocumentLoaded(pdfDocument);
        Result result = loadedDocumentResult.getAndSet(null);
        if (result != null) {
            result.success(true);
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

    public static FlutterPdfActivity getCurrentActivity() {
        return currentActivity;
    }
}
