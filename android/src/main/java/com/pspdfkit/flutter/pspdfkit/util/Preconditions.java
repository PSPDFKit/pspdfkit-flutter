package com.pspdfkit.flutter.pspdfkit.util;

import android.support.annotation.Nullable;

public class Preconditions {
    /**
     * Checks that the given <code>string</code> is not null and not empty,
     * or throws an {@link IllegalArgumentException} with the provided <code>readableName</code>.
     * @return Returns the original <code>string</code>.
     */
    public static String requireNotNullNotEmpty(@Nullable String string, @Nullable String readableName) {
        if (string == null) throw new IllegalArgumentException(String.format("%s may not be null.", readableName));
        if (string.isEmpty()) throw new IllegalArgumentException(String.format("%s may not be empty.", readableName));
        return string;
    }
}
