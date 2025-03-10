package com.pspdfkit.flutter.pspdfkit.annotations

import com.pspdfkit.ui.special_mode.controller.AnnotationTool
import com.pspdfkit.ui.special_mode.controller.AnnotationToolVariant
import com.pspdfkit.flutter.pspdfkit.api.AnnotationTool as FlutterAnnotationTool
import com.pspdfkit.ui.special_mode.controller.AnnotationTool as AndroidAnnotationTool

/**
 * Data class representing an Android annotation tool with its optional variant.
 * Some annotation tools are represented by a combination of annotationTool and AnnotationToolVariant on Android.
 */
data class AnnotationToolWithVariant(val annotationTool: AndroidAnnotationTool, val variant: AnnotationToolVariant? = null)

/**
 * Utility class for annotation-related operations, including mapping between Flutter and Android annotation tools.
 */
object AnnotationUtils {

    /**
     * Maps a Flutter AnnotationTool name to the corresponding Android AnnotationToolWithVariant.
     *
     * @param flutterToolName The name of the Flutter AnnotationTool enum value.
     * @return The corresponding Android AnnotationToolWithVariant, or null if no mapping exists.
     */
    fun getAndroidAnnotationToolWithVariantFromFlutterName(flutterToolName: String?): AnnotationToolWithVariant? {
        if (flutterToolName == null) return null

        // Try to find the matching Flutter enum value
        val flutterTool = FlutterAnnotationTool.values().find {
            it.name.equals(flutterToolName, ignoreCase = true) ||
                    it.name.replace("_", "").equals(flutterToolName, ignoreCase = true)
        }
        return mapFlutterToolToAndroidToolWithVariant(flutterTool)
    }

    /**
     * Maps a Flutter AnnotationTool to the corresponding Android AnnotationToolWithVariant.
     *
     * @param flutterTool The Flutter AnnotationTool enum value.
     * @return The corresponding Android AnnotationToolWithVariant, or null if no mapping exists.
     */
    fun getAndroidAnnotationToolWithVariantFromFlutterTool(flutterTool: FlutterAnnotationTool?): AnnotationToolWithVariant? {
        return mapFlutterToolToAndroidToolWithVariant(flutterTool)
    }
    
    /**
     * For backward compatibility - returns just the AnnotationTool without variant.
     */
    fun getAndroidAnnotationToolFromFlutterName(flutterToolName: String?): AndroidAnnotationTool? {
        return getAndroidAnnotationToolWithVariantFromFlutterName(flutterToolName)?.annotationTool
    }

    /**
     * For backward compatibility - returns just the AnnotationTool without variant.
     */
    fun getAndroidAnnotationToolFromFlutterTool(flutterTool: FlutterAnnotationTool?): AndroidAnnotationTool? {
        return getAndroidAnnotationToolWithVariantFromFlutterTool(flutterTool)?.annotationTool
    }
    
    /**
     * Maps a Flutter AnnotationTool to the corresponding Android AnnotationToolWithVariant.
     *
     * @param flutterTool The Flutter AnnotationTool enum value.
     * @return The corresponding Android AnnotationToolWithVariant, or null if no mapping exists.
     */
    private fun mapFlutterToolToAndroidToolWithVariant(flutterTool: FlutterAnnotationTool?): AnnotationToolWithVariant? {
        return when (flutterTool) {
            // Ink tools with variants
            FlutterAnnotationTool.INK_PEN -> AnnotationToolWithVariant(AndroidAnnotationTool.INK, AnnotationToolVariant.fromPreset(AnnotationToolVariant.Preset.PEN))
            FlutterAnnotationTool.INK_MAGIC -> AnnotationToolWithVariant(AndroidAnnotationTool.MAGIC_INK)
            FlutterAnnotationTool.INK_HIGHLIGHTER -> AnnotationToolWithVariant(AndroidAnnotationTool.INK, AnnotationToolVariant.fromPreset(AnnotationToolVariant.Preset.HIGHLIGHTER))
            
            // Free text tools with variants
            FlutterAnnotationTool.FREE_TEXT -> AnnotationToolWithVariant(AndroidAnnotationTool.FREETEXT)
            FlutterAnnotationTool.FREE_TEXT_CALL_OUT -> AnnotationToolWithVariant(AndroidAnnotationTool.FREETEXT_CALLOUT)
            
            // Shape tools
            FlutterAnnotationTool.STAMP -> AnnotationToolWithVariant(AndroidAnnotationTool.STAMP)
            FlutterAnnotationTool.IMAGE -> AnnotationToolWithVariant(AndroidAnnotationTool.IMAGE)
            
            // Text markup tools
            FlutterAnnotationTool.HIGHLIGHT -> AnnotationToolWithVariant(AndroidAnnotationTool.HIGHLIGHT)
            FlutterAnnotationTool.UNDERLINE -> AnnotationToolWithVariant(AndroidAnnotationTool.UNDERLINE)
            FlutterAnnotationTool.SQUIGGLY -> AnnotationToolWithVariant(AndroidAnnotationTool.SQUIGGLY)
            FlutterAnnotationTool.STRIKE_OUT -> AnnotationToolWithVariant(AndroidAnnotationTool.STRIKEOUT)
            
            // Line tools
            FlutterAnnotationTool.LINE -> AnnotationToolWithVariant(AndroidAnnotationTool.LINE)
            FlutterAnnotationTool.ARROW -> AnnotationToolWithVariant(AndroidAnnotationTool.LINE, AnnotationToolVariant.fromPreset(AnnotationToolVariant.Preset.ARROW))
            
            // Shape tools
            FlutterAnnotationTool.SQUARE -> AnnotationToolWithVariant(AndroidAnnotationTool.SQUARE)
            FlutterAnnotationTool.CIRCLE -> AnnotationToolWithVariant(AndroidAnnotationTool.CIRCLE)
            FlutterAnnotationTool.POLYGON -> AnnotationToolWithVariant(AndroidAnnotationTool.POLYGON)
            FlutterAnnotationTool.POLYLINE -> AnnotationToolWithVariant(AndroidAnnotationTool.POLYLINE)
            
            // Other tools
            FlutterAnnotationTool.ERASER -> AnnotationToolWithVariant(AndroidAnnotationTool.ERASER)
            FlutterAnnotationTool.CLOUDY -> AnnotationToolWithVariant(AndroidAnnotationTool.SQUARE, AnnotationToolVariant.fromPreset(AnnotationToolVariant.Preset.CLOUDY))
            FlutterAnnotationTool.NOTE -> AnnotationToolWithVariant(AndroidAnnotationTool.NOTE)
            FlutterAnnotationTool.SOUND -> AnnotationToolWithVariant(AndroidAnnotationTool.SOUND)
            FlutterAnnotationTool.SIGNATURE -> AnnotationToolWithVariant(AndroidAnnotationTool.SIGNATURE)
            FlutterAnnotationTool.REDACTION -> AnnotationToolWithVariant(AndroidAnnotationTool.REDACTION)
            
            // Measurement tools
            FlutterAnnotationTool.MEASUREMENT_AREA_RECT -> AnnotationToolWithVariant(AndroidAnnotationTool.MEASUREMENT_AREA_RECT)
            FlutterAnnotationTool.MEASUREMENT_AREA_POLYGON -> AnnotationToolWithVariant(AndroidAnnotationTool.MEASUREMENT_AREA_POLYGON)
            FlutterAnnotationTool.MEASUREMENT_AREA_ELLIPSE -> AnnotationToolWithVariant(AndroidAnnotationTool.MEASUREMENT_AREA_ELLIPSE)
            FlutterAnnotationTool.MEASUREMENT_PERIMETER -> AnnotationToolWithVariant(AndroidAnnotationTool.MEASUREMENT_PERIMETER)
            FlutterAnnotationTool.MEASUREMENT_DISTANCE -> AnnotationToolWithVariant(AndroidAnnotationTool.MEASUREMENT_DISTANCE)
            
            // Some Flutter tools don't have direct Android equivalents
            FlutterAnnotationTool.CARET,
            FlutterAnnotationTool.RICH_MEDIA,
            FlutterAnnotationTool.SCREEN,
            FlutterAnnotationTool.FILE,
            FlutterAnnotationTool.WIDGET,
            FlutterAnnotationTool.STAMP_IMAGE,
            FlutterAnnotationTool.LINK,
            null -> null
        }
    }
    
    /**
     * Maps an Android AnnotationTool to the corresponding Flutter AnnotationTool.
     *
     * @param androidTool The Android AnnotationTool.
     * @return The corresponding Flutter AnnotationTool, or null if no mapping exists.
     */
    fun mapAndroidToolToFlutterTool(androidTool: AndroidAnnotationTool?): FlutterAnnotationTool? {
        return when (androidTool) {
            AndroidAnnotationTool.INK -> FlutterAnnotationTool.INK_PEN
            AndroidAnnotationTool.MAGIC_INK -> FlutterAnnotationTool.INK_MAGIC
            AndroidAnnotationTool.FREETEXT -> FlutterAnnotationTool.FREE_TEXT
            AndroidAnnotationTool.FREETEXT_CALLOUT -> FlutterAnnotationTool.FREE_TEXT_CALL_OUT
            AndroidAnnotationTool.STAMP -> FlutterAnnotationTool.STAMP
            AndroidAnnotationTool.IMAGE -> FlutterAnnotationTool.IMAGE
            AndroidAnnotationTool.HIGHLIGHT -> FlutterAnnotationTool.HIGHLIGHT
            AndroidAnnotationTool.UNDERLINE -> FlutterAnnotationTool.UNDERLINE
            AndroidAnnotationTool.SQUIGGLY -> FlutterAnnotationTool.SQUIGGLY
            AndroidAnnotationTool.STRIKEOUT -> FlutterAnnotationTool.STRIKE_OUT
            AndroidAnnotationTool.LINE -> FlutterAnnotationTool.LINE
            AndroidAnnotationTool.SQUARE -> FlutterAnnotationTool.SQUARE
            AndroidAnnotationTool.CIRCLE -> FlutterAnnotationTool.CIRCLE
            AndroidAnnotationTool.POLYGON -> FlutterAnnotationTool.POLYGON
            AndroidAnnotationTool.POLYLINE -> FlutterAnnotationTool.POLYLINE
            AndroidAnnotationTool.ERASER -> FlutterAnnotationTool.ERASER
            AndroidAnnotationTool.NOTE -> FlutterAnnotationTool.NOTE
            AndroidAnnotationTool.SOUND -> FlutterAnnotationTool.SOUND
            AndroidAnnotationTool.SIGNATURE -> FlutterAnnotationTool.SIGNATURE
            AndroidAnnotationTool.REDACTION -> FlutterAnnotationTool.REDACTION
            AndroidAnnotationTool.MEASUREMENT_AREA_RECT -> FlutterAnnotationTool.MEASUREMENT_AREA_RECT
            AndroidAnnotationTool.MEASUREMENT_AREA_POLYGON -> FlutterAnnotationTool.MEASUREMENT_AREA_POLYGON
            AndroidAnnotationTool.MEASUREMENT_AREA_ELLIPSE -> FlutterAnnotationTool.MEASUREMENT_AREA_ELLIPSE
            AndroidAnnotationTool.MEASUREMENT_PERIMETER -> FlutterAnnotationTool.MEASUREMENT_PERIMETER
            AndroidAnnotationTool.MEASUREMENT_DISTANCE -> FlutterAnnotationTool.MEASUREMENT_DISTANCE
            AnnotationTool.NONE,
            AnnotationTool.MEASUREMENT_SCALE_CALIBRATION,
            AnnotationTool.CAMERA,
            AnnotationTool.INSTANT_COMMENT_MARKER,
            AnnotationTool.INSTANT_HIGHLIGHT_COMMENT,
            AnnotationTool.ANNOTATION_MULTI_SELECTION,
            null -> null
        }
    }
    
    /**
     * Maps an Android AnnotationToolWithVariant to the corresponding Flutter AnnotationTool.
     *
     * @param toolWithVariant The Android AnnotationToolWithVariant.
     * @return The corresponding Flutter AnnotationTool, or null if no mapping exists.
     */
    fun mapAndroidToolWithVariantToFlutterTool(toolWithVariant: AnnotationToolWithVariant?): FlutterAnnotationTool? {
        if (toolWithVariant == null) return null
        
        val tool = toolWithVariant.annotationTool
        val variant = toolWithVariant.variant
        
        // Special cases for tools with variants
        if (tool == AndroidAnnotationTool.INK && variant != null) {
            return when (variant.name) {
                AnnotationToolVariant.Preset.PEN.name -> FlutterAnnotationTool.INK_PEN
                AnnotationToolVariant.Preset.HIGHLIGHTER.name -> FlutterAnnotationTool.INK_HIGHLIGHTER
                else -> FlutterAnnotationTool.INK_PEN // Default to pen if variant not recognized
            }
        }
        
        if (tool == AndroidAnnotationTool.LINE && variant != null) {
            return when {
                variant.name == AnnotationToolVariant.Preset.ARROW.name -> FlutterAnnotationTool.ARROW
                else -> FlutterAnnotationTool.LINE
            }
        }
        
        if (tool == AndroidAnnotationTool.SQUARE && variant != null) {
            return when {
                variant.name == AnnotationToolVariant.Preset.CLOUDY.name -> FlutterAnnotationTool.CLOUDY
                else -> FlutterAnnotationTool.SQUARE
            }
        }
        
        // For all other cases, use the standard mapping
        return mapAndroidToolToFlutterTool(tool)
    }
}
