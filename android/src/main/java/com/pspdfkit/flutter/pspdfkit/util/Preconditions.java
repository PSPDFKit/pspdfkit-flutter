package com.pspdfkit.flutter.pspdfkit.util;

/*
 *   Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
 *
 *   THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 *   AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 *   UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 *   This notice may not be removed from this file.
 */
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pspdfkit.document.PdfDocument;
import com.pspdfkit.ui.PdfActivity;

public class Preconditions {
    /**
     * Checks that the given <code>string</code> is not null and not empty,
     * or throws an {@link IllegalArgumentException} with the provided <code>readableName</code>.
     *
     * @return Returns the original <code>string</code>.
     */
    public static String requireNotNullNotEmpty(@Nullable String string, @Nullable String readableName) {
        if (string == null)
            throw new IllegalArgumentException(String.format("%s may not be null.", readableName));
        if (string.isEmpty())
            throw new IllegalArgumentException(String.format("%s may not be empty.", readableName));
        return string;
    }

    /**
     * Checks if the given assertion is satisfied (evaluates to true) and if not,
     * throws {@link IllegalStateException} with the provided message.
     *
     * @param stateAssertion   Assertion to check against.
     * @param exceptionMessage Message of the {@link IllegalStateException}, in case it needs to be thrown.
     */
    public static void requireState(boolean stateAssertion, @Nullable String exceptionMessage) {
        if (!stateAssertion) {
            throw new IllegalStateException(exceptionMessage);
        }
    }

    /**
     * Checks that the document has been correctly presented and that the static instance of
     * the Flutter Activity is not null.
     *
     * @param flutterPdfActivity Flutter Activity to check that may not be null.
     * @param invokedMethod      Invoked method to use in the error message in case of an illegal state.
     * @return Returns the loaded document.
     */
    @NonNull
    public static PdfDocument requireDocumentNotNull(@Nullable PdfActivity flutterPdfActivity, @NonNull String invokedMethod) {
        if (flutterPdfActivity == null) {
            throw new IllegalStateException(String.format("Before using \"%s\" " +
                    "the document needs to be presented by calling \"Pspdfkit.present()\".", invokedMethod));
        }
        requireState(flutterPdfActivity.getPdfFragment() != null, "PdfFragment may not be null.");
        requireState(flutterPdfActivity.getPdfFragment().getDocument() != null, "PdfDocument may not be null.");

        return flutterPdfActivity.getPdfFragment().getDocument();
    }
}
