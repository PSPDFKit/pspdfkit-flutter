package com.pspdfkit.flutter.pspdfkit.util

import android.graphics.Color

object ColorUtil {

    @JvmStatic
     fun extractColor(colorStrings: String?): Int {
        if (colorStrings == null)
            return Color.BLUE
        return extractColors(listOf(colorStrings)).first()
    }

    @JvmStatic
    private fun extractColors(colorStrings: List<String?>): MutableList<Int> {
        val colors = mutableListOf<Int>()
        colorStrings.let {
            for (i in colorStrings) {
                if (i == null)
                    continue
                colors.add(Color.parseColor(i))
            }
        }
        return colors
    }
}