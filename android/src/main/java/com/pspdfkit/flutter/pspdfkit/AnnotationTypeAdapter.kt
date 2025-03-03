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
                // Basic annotations
                "pspdfkit/ink" -> EnumSet.of(AnnotationType.INK)
                "pspdfkit/link" -> EnumSet.of(AnnotationType.LINK)
                "pspdfkit/note" -> EnumSet.of(AnnotationType.NOTE)
                "pspdfkit/text" -> EnumSet.of(AnnotationType.FREETEXT)
                
                // Markup annotations
                "pspdfkit/markup/highlight" -> EnumSet.of(AnnotationType.HIGHLIGHT)
                "pspdfkit/markup/squiggly" -> EnumSet.of(AnnotationType.SQUIGGLY)
                "pspdfkit/markup/strikeout" -> EnumSet.of(AnnotationType.STRIKEOUT)
                "pspdfkit/markup/underline" -> EnumSet.of(AnnotationType.UNDERLINE)
                "pspdfkit/markup/redaction" -> EnumSet.of(AnnotationType.REDACT)
                
                // Shape annotations
                "pspdfkit/shape/ellipse" -> EnumSet.of(AnnotationType.CIRCLE)
                "pspdfkit/shape/line" -> EnumSet.of(AnnotationType.LINE)
                "pspdfkit/shape/polygon" -> EnumSet.of(AnnotationType.POLYGON)
                "pspdfkit/shape/polyline" -> EnumSet.of(AnnotationType.POLYLINE)
                "pspdfkit/shape/rectangle" -> EnumSet.of(AnnotationType.SQUARE)
                
                // Media annotations
                "pspdfkit/image" -> EnumSet.of(AnnotationType.STAMP)
                "pspdfkit/sound" -> EnumSet.of(AnnotationType.SOUND)
                "pspdfkit/richmedia" -> EnumSet.of(AnnotationType.RICHMEDIA)
                "pspdfkit/screen" -> EnumSet.of(AnnotationType.SCREEN)
                "pspdfkit/3d" -> EnumSet.of(AnnotationType.TYPE3D)
                
                // File annotations
                "pspdfkit/file" -> EnumSet.of(AnnotationType.FILE)
                
                // Other annotations
                "pspdfkit/stamp" -> EnumSet.of(AnnotationType.STAMP)
                "pspdfkit/caret" -> EnumSet.of(AnnotationType.CARET)
                "pspdfkit/popup" -> EnumSet.of(AnnotationType.POPUP)
                "pspdfkit/widget" -> EnumSet.of(AnnotationType.WIDGET)
                "pspdfkit/watermark" -> EnumSet.of(AnnotationType.WATERMARK)
                
                // Special types
                "pspdfkit/none" -> EnumSet.of(AnnotationType.NONE)
                "pspdfkit/undefined" -> EnumSet.of(AnnotationType.NONE)
                "pspdfkit/all", "all" -> EnumSet.allOf(AnnotationType::class.java)
                
                // Fallback
                else -> EnumSet.of(AnnotationType.NONE)
            }
        }
    }
}
