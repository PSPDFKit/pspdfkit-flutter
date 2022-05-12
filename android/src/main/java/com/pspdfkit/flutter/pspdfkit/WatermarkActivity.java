package com.pspdfkit.flutter.pspdfkit;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PixelFormat;
import android.graphics.Point;
import android.graphics.PointF;
import android.graphics.Rect;
import android.graphics.RectF;
import android.os.Bundle;
import androidx.annotation.IntRange;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.UiThread;
import com.pspdfkit.document.PdfDocument;
import com.pspdfkit.ui.PdfActivity;
import com.pspdfkit.ui.PdfFragment;
import com.pspdfkit.ui.PdfOutlineView;
import com.pspdfkit.ui.PdfThumbnailBar;
import com.pspdfkit.ui.PdfThumbnailGrid;
import com.pspdfkit.ui.drawable.PdfDrawable;
import com.pspdfkit.ui.drawable.PdfDrawableProvider;
import java.util.Arrays;
import java.util.List;

/**
 * For communication with the PSPDFKit plugin, we keep a static reference to the current
 * activity.
 */

public class WatermarkActivity extends FlutterPdfActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        final PdfDrawableProvider customTestDrawableProvider = new PdfDrawableProvider() {
            @Nullable
            @Override
            public List<? extends PdfDrawable> getDrawablesForPage(
                    @NonNull Context context,
                    @NonNull PdfDocument document,
                    @IntRange(from = 0) int pageIndex) {
                return Arrays.asList(
                        // You can pass in multiple drawables if needed. Here is a single text watermark,
                        // tilted by 45 degrees with the bottom-left corner at (350, 350) in PDF coordinates.
//                        new WatermarkDrawable("Riservato", new Point(150, 750))
                );
            }
        };

        // Register the drawable provider on `PdfFragment` to provide drawables to document pages.
        getPdfFragment().addDrawableProvider(customTestDrawableProvider);

        // Also register the drawable provider on the thumbnail bar and thumbnail grid.
        PdfThumbnailBar thumbnailBarView = getPSPDFKitViews().getThumbnailBarView();

        if (thumbnailBarView != null) {
            thumbnailBarView.addDrawableProvider(customTestDrawableProvider);
        }
        PdfThumbnailGrid thumbnailGridView = getPSPDFKitViews().getThumbnailGridView();
        if (thumbnailGridView != null) {
            thumbnailGridView.addDrawableProvider(customTestDrawableProvider);
        }

        // Outline displays page previews in the bookmarks list. Bookmarks are enabled in this example
        // so you need to register the drawable provider on the outline view too.
        PdfOutlineView outlineView = getPSPDFKitViews().getOutlineView();
        if (outlineView != null) {
            outlineView.addDrawableProvider(customTestDrawableProvider);
        }
    }
}
