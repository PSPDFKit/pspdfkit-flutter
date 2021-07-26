/*
 *   Copyright © 2017-2021 PSPDFKit GmbH. All rights reserved.
 *
 *   The PSPDFKit Sample applications are licensed with a modified BSD license.
 *   Please see License for details. This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PixelFormat;
import android.graphics.Point;
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
 * Activity showing how to draw custom drawables on the {@link PdfFragment}, the {@link
 * PdfThumbnailGrid}, and the {@link PdfThumbnailBar} using Drawable API.
 */
public class FlutterWatermarkActivity extends FlutterPdfActivity {
    @Nullable static String watermarkString;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        final PdfDrawableProvider customTestDrawableProvider = getCustomTestDrawableProvider();

        getPdfFragment().addDrawableProvider(customTestDrawableProvider);

        PdfThumbnailBar thumbnailBarView = getPSPDFKitViews().getThumbnailBarView();
        if (thumbnailBarView != null) {
            thumbnailBarView.addDrawableProvider(customTestDrawableProvider);
        }

        PdfThumbnailGrid thumbnailGridView = getPSPDFKitViews().getThumbnailGridView();
        if (thumbnailGridView != null) {
            thumbnailGridView.addDrawableProvider(customTestDrawableProvider);
        }

        PdfOutlineView outlineView = getPSPDFKitViews().getOutlineView();
        if (outlineView != null) {
            outlineView.addDrawableProvider(customTestDrawableProvider);
        }
    }

    @NonNull
    private PdfDrawableProvider getCustomTestDrawableProvider() {
        return new PdfDrawableProvider() {
            @Nullable
            @Override
            public List<? extends PdfDrawable> getDrawablesForPage(@NonNull Context context, @NonNull PdfDocument document, @IntRange(from = 0) int pageIndex) {
                if (watermarkString == null) {
                    watermarkString = "WATERMARK";
                }
                return Arrays.asList(
                        new TwoSquaresDrawable(new RectF(0f, 400f, 400f, 0f)),
                        // Text watermark, tilted by 45 degrees with a bottom-left corner at (350,
                        // 350) in PDF coordinates.
                        new WatermarkDrawable(watermarkString, new Point(350, 350)));
            }
        };
    }

    /**
     * An implementation of {@link PdfDrawable}, which shows two semi-transparent squares in the
     * bottom-left corner.
     */
    class TwoSquaresDrawable extends PdfDrawable {

        private final Paint redPaint = new Paint();
        private final Paint bluePaint = new Paint();
        @NonNull private final RectF pageCoordinates;
        @NonNull private final RectF screenCoordinates = new RectF();

        public TwoSquaresDrawable(@NonNull final RectF pageCoordinates) {
            this.pageCoordinates = pageCoordinates;
            this.bluePaint.setColor(Color.BLUE);
            this.bluePaint.setStyle(Paint.Style.FILL);
            this.bluePaint.setAlpha(50);

            this.redPaint.setColor(Color.RED);
            this.redPaint.setStyle(Paint.Style.FILL);
            this.redPaint.setAlpha(50);
        }

        /** Here all the drawing is performed. Keep this method fast to maintain 60 fps. */
        @Override
        public void draw(@NonNull Canvas canvas) {
            Rect bounds = getBounds();
            canvas.drawRect(
                    bounds.left,
                    bounds.top,
                    bounds.right - bounds.width() / 2,
                    bounds.bottom - bounds.height() / 2,
                    redPaint);

            canvas.drawRect(
                    bounds.left + bounds.width() / 2,
                    bounds.top + bounds.height() / 2,
                    bounds.right,
                    bounds.bottom,
                    bluePaint);
        }

        /**
         * PSPDFKit calls this method every time the page was moved or resized on screen. It will
         * provide a fresh transformation for calculating screen coordinates from PDF coordinates.
         */
        @Override
        public void updatePDFToViewTransformation(@NonNull Matrix matrix) {
            super.updatePDFToViewTransformation(matrix);
            updateScreenCoordinates();
        }

        private void updateScreenCoordinates() {
            // Calculate the screen coordinates by applying the PDF-to-view transformation.
            getPDFToPageTransformation().mapRect(screenCoordinates, pageCoordinates);

            // Rounding out ensure no clipping of content.
            final Rect bounds = getBounds();
            screenCoordinates.roundOut(bounds);
            setBounds(bounds);
        }

        @UiThread
        @Override
        public void setAlpha(int alpha) {
            bluePaint.setAlpha(alpha);
            redPaint.setAlpha(alpha);
            // Drawable invalidation is only allowed from a UI-thread.
            invalidateSelf();
        }

        @UiThread
        @Override
        public void setColorFilter(ColorFilter colorFilter) {
            bluePaint.setColorFilter(colorFilter);
            redPaint.setColorFilter(colorFilter);
            // Drawable invalidation is only allowed from a UI-thread.
            invalidateSelf();
        }

        @Override
        public int getOpacity() {
            return PixelFormat.TRANSLUCENT;
        }
    }

    /**
     * An implementation of {@link PdfDrawable}, which shows a semi-transparent text tilted by 45
     * degrees.
     */
    class WatermarkDrawable extends PdfDrawable {

        private final Paint redPaint = new Paint();
        @NonNull private final RectF pageCoordinates = new RectF();
        @NonNull private final RectF screenCoordinates = new RectF();
        private String text;

        public WatermarkDrawable(String text, Point startingPoint) {
            this.text = text;

            redPaint.setColor(Color.RED);
            redPaint.setStyle(Paint.Style.FILL);
            redPaint.setAlpha(50);
            redPaint.setTextSize(100);
            calculatePageCoordinates(text, startingPoint);
        }

        private void calculatePageCoordinates(String text, Point point) {
            Rect textBounds = new Rect();
            redPaint.getTextBounds(text, 0, text.length(), textBounds);
            pageCoordinates.set(
                    point.x, point.y + textBounds.height(), point.x + textBounds.width(), point.y);
        }

        private void updateScreenCoordinates() {
            getPDFToPageTransformation().mapRect(screenCoordinates, pageCoordinates);

            // Rounding out ensure no clipping of content.
            final Rect bounds = getBounds();
            screenCoordinates.roundOut(bounds);
            setBounds(bounds);
        }
        /** Here all the drawing is performed. Keep this method fast to maintain 60 fps. */
        @Override
        public void draw(@NonNull Canvas canvas) {
            Rect bounds = getBounds();
            canvas.save();
            // Rotate text by 45 degrees.
            canvas.rotate(-45, bounds.left, bounds.bottom);

            // Recalculate text size to much new bounds.
            setTextSizeForWidth(redPaint, bounds.width(), text);

            canvas.drawText(text, bounds.left, bounds.bottom, redPaint);
            canvas.restore();
        }

        private void setTextSizeForWidth(Paint paint, float desiredWidth, String text) {

            // Pick a reasonably large value for the test.
            final float testTextSize = 60f;

            // Get the bounds of the text, using our testTextSize.
            paint.setTextSize(testTextSize);
            Rect bounds = new Rect();
            paint.getTextBounds(text, 0, text.length(), bounds);

            // Calculate the desired size as a proportion of our testTextSize.
            float desiredTextSize = testTextSize * desiredWidth / bounds.width();

            // Set the paint for that size.
            paint.setTextSize(desiredTextSize);
        }
        /**
         * PSPDFKit calls this method every time the page was moved or resized on screen. It will
         * provide a fresh transformation for calculating screen coordinates from PDF coordinates.
         */
        @Override
        public void updatePDFToViewTransformation(@NonNull Matrix matrix) {
            super.updatePDFToViewTransformation(matrix);
            updateScreenCoordinates();
        }

        @UiThread
        @Override
        public void setAlpha(int alpha) {
            redPaint.setAlpha(alpha);
            // Drawable invalidation is only allowed from a UI-thread.
            invalidateSelf();
        }

        @UiThread
        @Override
        public void setColorFilter(ColorFilter colorFilter) {
            redPaint.setColorFilter(colorFilter);
            // Drawable invalidation is only allowed from a UI-thread.
            invalidateSelf();
        }

        @Override
        public int getOpacity() {
            return PixelFormat.TRANSLUCENT;
        }
    }
}
