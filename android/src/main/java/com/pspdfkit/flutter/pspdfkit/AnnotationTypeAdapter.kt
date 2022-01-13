package com.pspdfkit.flutter.pspdfkit

import com.pspdfkit.annotations.AnnotationType
import java.util.EnumSet

/**
 * Annotation adapter that converts an Instant JSON annotation [String] type into a proper [AnnotationType].
 * If the annotation type is not supported the adapter will return an enum set of [AnnotationType.NONE].
 */
class AnnotationTypeAdapter {
    companion object {
        @JvmStatic
        fun fromString(type: String): EnumSet<AnnotationType> {
            return when (type) {
                "pspdfkit/ink" -> EnumSet.of(AnnotationType.INK)
                "pspdfkit/link" -> EnumSet.of(AnnotationType.LINK)
                "pspdfkit/markup/highlight" -> EnumSet.of(AnnotationType.HIGHLIGHT)
                "pspdfkit/markup/squiggly" -> EnumSet.of(AnnotationType.SQUIGGLY)
                "pspdfkit/markup/strikeout" -> EnumSet.of(AnnotationType.STRIKEOUT)
                "pspdfkit/markup/underline" -> EnumSet.of(AnnotationType.UNDERLINE)
                "pspdfkit/note" -> EnumSet.of(AnnotationType.NOTE)
                "pspdfkit/shape/ellipse" -> EnumSet.of(AnnotationType.CIRCLE)
                "pspdfkit/shape/line" -> EnumSet.of(AnnotationType.LINE)
                "pspdfkit/shape/polygon" -> EnumSet.of(AnnotationType.POLYGON)
                "pspdfkit/shape/rectangle" -> EnumSet.of(AnnotationType.SQUARE)
                "pspdfkit/text" -> EnumSet.of(AnnotationType.FREETEXT)
                "all", "pspdfkit/all" -> EnumSet.allOf(AnnotationType::class.java)
                else -> EnumSet.of(AnnotationType.NONE)
            }
        }
    }
}
