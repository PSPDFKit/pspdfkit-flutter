package com.pspdfkit.flutter.pspdfkit;

import static java.lang.Math.atan2;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PixelFormat;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.RectF;

import androidx.annotation.NonNull;
import androidx.annotation.UiThread;

import com.pspdfkit.ui.drawable.PdfDrawable;


class WatermarkDrawable extends PdfDrawable {

    private final Paint paint = new Paint();
    @NonNull
    private final RectF pageCoordinates = new RectF();
    @NonNull
    private final RectF screenCoordinates = new RectF();
    private final RectF pageBox;
    private String text = "";

    public WatermarkDrawable(String watermarkText, String watermarkColor, Integer watermarkSize, Double watermarkOpacity, RectF pageBox) {
        this.text = watermarkText;

        paint.setColor(Color.parseColor(watermarkColor));
        paint.setStyle(Paint.Style.FILL);
        int opacity = (int) (watermarkOpacity * 100);
        paint.setAlpha(opacity);
        paint.setTextSize(watermarkSize);

        this.pageBox = pageBox;

        Rect textBounds = new Rect();
        paint.getTextBounds(text, 0, text.length(), textBounds);
        int textWidth = textBounds.width();

        // lunghezza diagonale
        double diagonalLength = Math.sqrt(Math.pow(pageBox.top, 2) + Math.pow(pageBox.right, 2));

        if (textWidth < diagonalLength) {

            // calcolo quante volte devo ripetere il suo nome per coprire tutta la diagonale
            double cycles = Math.round(diagonalLength / textWidth);
            StringBuilder textBuilder = new StringBuilder(text);
            for (int i = 0; i < cycles; i++) {
                textBuilder.append(" ").append(watermarkText);
            }
            text = textBuilder.toString();
        }

        calculatePageCoordinates(text, new Point(0, (int) pageBox.top));
    }

    private void calculatePageCoordinates(String text, Point point) {
        Rect textBounds = new Rect();
        paint.getTextBounds(text, 0, text.length(), textBounds);
        pageCoordinates.set(
                point.x, point.y + textBounds.height(), point.x + textBounds.width(), point.y);

    }

    private void updateScreenCoordinates() {
        getPdfToPageTransformation().mapRect(screenCoordinates, pageCoordinates);

        // Rounding out ensure no clipping of content.
        final Rect bounds = getBounds();
        screenCoordinates.roundOut(bounds);
        setBounds(bounds);

    }

    /**
     * Here all the drawing is performed. Keep this method fast to maintain 60 fps.
     */
    @Override
    public void draw(@NonNull Canvas canvas) {
        Rect bounds = getBounds();
        canvas.save();

        double rotation = Math.toDegrees(atan2(pageBox.top, pageBox.right));
        canvas.rotate((float) rotation, bounds.left, bounds.bottom);
        setTextSizeForWidth(paint, bounds.width(), text);
        canvas.drawText(text, bounds.left, bounds.bottom, paint);
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
    public void updatePdfToViewTransformation(@NonNull Matrix matrix) {
        super.updatePdfToViewTransformation(matrix);
        updateScreenCoordinates();
    }

    @UiThread
    @Override
    public void setAlpha(int alpha) {
        paint.setAlpha(alpha);
        // Drawable invalidation is only allowed from a UI-thread.
        invalidateSelf();
    }

    @UiThread
    @Override
    public void setColorFilter(ColorFilter colorFilter) {
        paint.setColorFilter(colorFilter);
        // Drawable invalidation is only allowed from a UI-thread.
        invalidateSelf();
    }

    @Override
    public int getOpacity() {
        return PixelFormat.TRANSLUCENT;
    }
}