//
//  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

package com.pspdfkit.flutter.pspdfkit

import android.content.Context
import android.graphics.Color
import androidx.core.util.Pair
import com.pspdfkit.annotations.AnnotationType
import com.pspdfkit.annotations.AnnotationType.CIRCLE
import com.pspdfkit.annotations.AnnotationType.FILE
import com.pspdfkit.annotations.AnnotationType.FREETEXT
import com.pspdfkit.annotations.AnnotationType.HIGHLIGHT
import com.pspdfkit.annotations.AnnotationType.INK
import com.pspdfkit.annotations.AnnotationType.LINE
import com.pspdfkit.annotations.AnnotationType.NOTE
import com.pspdfkit.annotations.AnnotationType.POLYGON
import com.pspdfkit.annotations.AnnotationType.POLYLINE
import com.pspdfkit.annotations.AnnotationType.REDACT
import com.pspdfkit.annotations.AnnotationType.SOUND
import com.pspdfkit.annotations.AnnotationType.SQUARE
import com.pspdfkit.annotations.AnnotationType.SQUIGGLY
import com.pspdfkit.annotations.AnnotationType.STAMP
import com.pspdfkit.annotations.AnnotationType.STRIKEOUT
import com.pspdfkit.annotations.AnnotationType.UNDERLINE
import com.pspdfkit.annotations.LineEndType
import com.pspdfkit.annotations.configuration.AnnotationConfiguration
import com.pspdfkit.annotations.configuration.AnnotationProperty
import com.pspdfkit.annotations.configuration.EraserToolConfiguration
import com.pspdfkit.annotations.configuration.FileAnnotationConfiguration
import com.pspdfkit.annotations.configuration.FreeTextAnnotationConfiguration
import com.pspdfkit.annotations.configuration.InkAnnotationConfiguration
import com.pspdfkit.annotations.configuration.LineAnnotationConfiguration
import com.pspdfkit.annotations.configuration.MarkupAnnotationConfiguration
import com.pspdfkit.annotations.configuration.MeasurementAreaAnnotationConfiguration
import com.pspdfkit.annotations.configuration.MeasurementDistanceAnnotationConfiguration
import com.pspdfkit.annotations.configuration.MeasurementPerimeterAnnotationConfiguration
import com.pspdfkit.annotations.configuration.NoteAnnotationConfiguration
import com.pspdfkit.annotations.configuration.RedactionAnnotationConfiguration
import com.pspdfkit.annotations.configuration.ShapeAnnotationConfiguration
import com.pspdfkit.annotations.configuration.SoundAnnotationConfiguration
import com.pspdfkit.annotations.configuration.StampAnnotationConfiguration
import com.pspdfkit.annotations.stamps.StampPickerItem
import com.pspdfkit.configuration.annotations.AnnotationAggregationStrategy
import com.pspdfkit.ui.fonts.Font
import com.pspdfkit.ui.inspector.views.BorderStylePreset
import com.pspdfkit.ui.special_mode.controller.AnnotationTool
import java.util.EnumSet

const val DEFAULT_COLOR = "color"
const val DEFAULT_FILL_COLOR = "fillColor"
const val DEFAULT_THICKNESS = "thickness"
const val DEFAULT_ALPHA = "alpha"
const val AVAILABLE_COLORS = "availableColors"
const val AVAILABLE_FILL_COLORS = "availableFillColors"
const val MAX_ALPHA = "maxAlpha"
const val MIN_ALPHA = "minAlpha"
const val MAX_THICKNESS = "maxThickness"
const val MIN_THICKNESS = "minThickness"
const val CUSTOM_COLOR_PICKER_ENABLED = "customColorPickerEnabled"
const val Z_INDEX_EDITING_ENABLED = "zIndexEditingEnabled"
const val AGGREGATION_STRATEGY = "aggregationStrategy"
const val PREVIEW_ENABLED = "previewEnabled"
const val SUPPORTED_PROPERTIES = "supportedProperties"
const val FORCE_DEFAULTS = "forceDefaults"
const val AVAILABLE_BORDER_STYLES_PRESETS = "availableBorderStylePresets"
const val DEFAULT_BORDER_STYLE = "borderStyle"
const val AUDION_SAMPLING_RATE = "audioSamplingRate"
const val AUDIO_RECORDING_TIME_LIMIT = "audioRecordingTimeLimit"
const val AVAILABLE_STAMP_ITEMS = "availableStampPickers"
const val DEFAULT_ICON_NAME = "defaultIconName"
const val AVAILABLE_ICON_NAMES = "availableIconNames"
const val DEFAULT_LINE_END = "lineEndStyle"
const val AVAILABLE_LINE_ENDS = "availableLineEnds"
const val DEFAULT_TEXT_SIZE = "fontSize"
const val MIN_TEXT_SIZE = "minimumFontSize"
const val MAX_TEXT_SIZE = "maximumFontSize"
const val DEFAULT_FONT = "fontName"
const val AVAILABLE_FONTS = "availableFonts"
const val OVERLAY_TEXT = "overlayText"
const val REPEAT_OVERLAY_TEXT = "repeatOverlayText"

const val ANNOTATION_INK_PEN = "inkPen"
const val ANNOTATION_INK_MAGIC = "inkMagic"
const val ANNOTATION_INK_HIGHLIGHTER = "inkHighlighter"
const val ANNOTATION_FREE_TEXT = "freeText"
const val ANNOTATION_FREE_TEXT_CALL_OUT = "freeTextCallout"
const val ANNOTATION_STAMP = "stamp"
const val ANNOTATION_NOTE = "note"
const val ANNOTATION_HIGHLIGHT = "highlight"
const val ANNOTATION_UNDERLINE = "underline"
const val ANNOTATION_SQUIGGLY = "squiggly"
const val ANNOTATION_STRIKE_OUT = "strikeOut"
const val ANNOTATION_SQUARE = "square"
const val ANNOTATION_CIRCLE = "circle"
const val ANNOTATION_LINE = "line"
const val ANNOTATION_ARROW = "arrow"
const val ANNOTATION_ERASER = "eraser"
const val ANNOTATION_FILE = "file"
const val ANNOTATION_POLYGON = "polygon"
const val ANNOTATION_POLYLINE = "polyline"
const val ANNOTATION_SOUND = "sound"
const val ANNOTATION_REDACTION = "redaction"
const val ANNOTATION_IMAGE = "image"
const val ANNOTATION_AUDIO = "audio"
const val ANNOTATION_MEASUREMENT_AREA_RECT = "measurementAreaRect"
const val ANNOTATION_MEASUREMENT_AREA_POLYGON = "measurementAreaPolygon"
const val ANNOTATION_MEASUREMENT_AREA_ELLIPSE = "measurementAreaEllipse"
const val ANNOTATION_MEASUREMENT_PERIMETER = "measurementPerimeter"
const val ANNOTATION_MEASUREMENT_DISTANCE = "measurementDistance"

// This class is used to convert annotation configuration from React Native to PSPDFKit. It is used in the `ReactPdfViewManager` class.
class AnnotationConfigurationAdaptor {

    companion object {

        private val configurations = mutableMapOf<AnnotationType, AnnotationConfiguration>()

        @JvmStatic
        fun convertAnnotationConfigurations(
            context: Context, annotationConfigurations: Map<*, *>
        ): Map<AnnotationType, AnnotationConfiguration> {

            val iterator = annotationConfigurations.keys.iterator()

            while (iterator.hasNext()) {
                val key = iterator.next()
                val configuration = (annotationConfigurations[key] as Map<*, *>?) ?: continue
                when (key) {
                    ANNOTATION_INK_PEN -> {
                        configurations[INK] =
                            parseInkAnnotationConfiguration(context, configuration)
                    }

                    ANNOTATION_INK_HIGHLIGHTER -> {
                        configurations[AnnotationTool.INK.toAnnotationType()] =
                            parseInkAnnotationConfiguration(context, configuration)
                    }

                    ANNOTATION_INK_MAGIC -> {
                        configurations[AnnotationTool.MAGIC_INK.toAnnotationType()] =
                            parseInkAnnotationConfiguration(context, configuration)
                    }

                    ANNOTATION_UNDERLINE -> {
                        configurations[UNDERLINE] =
                            parseMarkupAnnotationConfiguration(context, configuration, UNDERLINE)
                    }

                    ANNOTATION_FREE_TEXT -> {
                        configurations[FREETEXT] =
                            parserFreeTextAnnotationConfiguration(context, configuration)
                    }

                    ANNOTATION_LINE -> {
                        configurations[LINE] =
                            parseLineAnnotationConfiguration(
                                context,
                                configuration,
                                LINE,
                                AnnotationTool.LINE
                            )
                    }

                    ANNOTATION_NOTE -> {
                        configurations[NOTE] =
                            parseNoteAnnotationConfiguration(context, configuration)
                    }

                    ANNOTATION_STAMP -> {
                        configurations[STAMP] =
                            parseStampAnnotationConfiguration(context, configuration)
                    }

                    ANNOTATION_FILE -> {
                        configurations[FILE] =
                            parseFileAnnotationConfiguration(configuration)
                    }

                    ANNOTATION_REDACTION -> {
                        configurations[REDACT] =
                            parseRedactAnnotationConfiguration(context, configuration)
                    }

                    ANNOTATION_SOUND -> {
                        configurations[SOUND] =
                            parseSoundAnnotationConfiguration(configuration)
                    }

                    ANNOTATION_HIGHLIGHT -> {
                        configurations[HIGHLIGHT] =
                            parseMarkupAnnotationConfiguration(context, configuration, HIGHLIGHT)
                    }

                    ANNOTATION_SQUARE -> {
                        configurations[SQUARE] =
                            parseShapeAnnotationConfiguration(context, configuration, SQUARE)
                    }

                    ANNOTATION_CIRCLE -> {
                        configurations[CIRCLE] =
                            parseShapeAnnotationConfiguration(context, configuration, CIRCLE)
                    }

                    ANNOTATION_POLYGON -> {
                        configurations[POLYGON] =
                            parseShapeAnnotationConfiguration(context, configuration, POLYGON)
                    }

                    ANNOTATION_POLYLINE -> {
                        configurations[POLYLINE] =
                            parseLineAnnotationConfiguration(
                                context,
                                configuration,
                                POLYLINE,
                                AnnotationTool.POLYLINE
                            )
                    }

                    ANNOTATION_IMAGE -> {
                        configurations[AnnotationTool.IMAGE.toAnnotationType()] =
                            parseStampAnnotationConfiguration(context, configuration)
                    }

                    ANNOTATION_ARROW -> {
                        configurations[LINE] =
                            parseLineAnnotationConfiguration(
                                context,
                                configuration,
                                LINE,
                                AnnotationTool.LINE
                            )
                    }

                    ANNOTATION_SQUIGGLY -> {
                        configurations[SQUIGGLY] =
                            parseMarkupAnnotationConfiguration(context, configuration, SQUIGGLY)
                    }

                    ANNOTATION_STRIKE_OUT -> {
                        configurations[STRIKEOUT] =
                            parseMarkupAnnotationConfiguration(context, configuration, STRIKEOUT)
                    }

                    ANNOTATION_ERASER -> {
                        configurations[AnnotationTool.ERASER.toAnnotationType()] =
                            parseEraserAnnotationConfiguration(configuration)
                    }

                    ANNOTATION_AUDIO -> {
                        configurations[SOUND] =
                            parseSoundAnnotationConfiguration(configuration)
                    }

                    ANNOTATION_FREE_TEXT_CALL_OUT -> {
                        configurations[AnnotationTool.FREETEXT_CALLOUT.toAnnotationType()] =
                            parserFreeTextAnnotationConfiguration(context, configuration)
                    }

                    ANNOTATION_MEASUREMENT_AREA_RECT -> {
                        configurations[AnnotationTool.MEASUREMENT_AREA_RECT.toAnnotationType()] =
                            parserMeasurementAreaAnnotationConfiguration(context, configuration)
                    }

                    ANNOTATION_MEASUREMENT_AREA_POLYGON -> {
                        configurations[AnnotationTool.MEASUREMENT_AREA_POLYGON.toAnnotationType()] =
                            parserMeasurementAreaAnnotationConfiguration(context, configuration)
                    }

                    ANNOTATION_MEASUREMENT_AREA_ELLIPSE -> {
                        configurations[AnnotationTool.MEASUREMENT_AREA_ELLIPSE.toAnnotationType()] =
                            parserMeasurementAreaAnnotationConfiguration(context, configuration)
                    }

                    ANNOTATION_MEASUREMENT_PERIMETER -> {
                        configurations[AnnotationTool.MEASUREMENT_PERIMETER.toAnnotationType()] =
                            parseMeasurementPerimeterAnnotationConfiguration(context, configuration)
                    }

                    ANNOTATION_MEASUREMENT_DISTANCE -> {
                        configurations[AnnotationTool.MEASUREMENT_DISTANCE.toAnnotationType()] =
                            parseMeasurementDistanceConfiguration(context, configuration)
                    }

                    else -> {
                        throw IllegalArgumentException("Unknown annotation type: $key")
                    }
                }
            }
            return configurations
        }

        private fun parserMeasurementAreaAnnotationConfiguration(
            context: Context,
            configuration: Map<*, *>
        ): AnnotationConfiguration {
            val builder = MeasurementAreaAnnotationConfiguration.builder(context)
            val iterator = configuration.keys.iterator()
            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    DEFAULT_COLOR -> builder.setDefaultColor(
                        extractColor(configuration[key] as String)
                    )

                    DEFAULT_ALPHA -> builder.setDefaultAlpha((configuration[key] as Double).toFloat())
                    DEFAULT_THICKNESS -> builder.setDefaultThickness(
                        (configuration[key] as Double).toFloat()
                    )

                    AVAILABLE_COLORS -> (configuration[key] as List<*>?)?.let { colors ->
                        builder.setAvailableColors(
                            extractColors(colors.map { it as String })
                        )
                    }

                    MAX_ALPHA -> builder.setMaxAlpha((configuration[key] as Double).toFloat())
                    MIN_ALPHA -> builder.setMinAlpha((configuration[key] as Double).toFloat())
                    MAX_THICKNESS -> builder.setMaxThickness((configuration[key] as Double).toFloat())
                    MIN_THICKNESS -> builder.setMinThickness((configuration[key] as Double).toFloat())
                    CUSTOM_COLOR_PICKER_ENABLED -> builder.setCustomColorPickerEnabled(
                        configuration[key] as Boolean
                    )

                    PREVIEW_ENABLED -> builder.setPreviewEnabled(configuration[key] as Boolean)
                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    else -> {
                        throw IllegalArgumentException("Unknown annotation configuration key: $key")
                    }
                }
            }
            return builder.build()
        }

        private fun parseMeasurementDistanceConfiguration(
            context: Context,
            configuration: Map<*, *>
        ): AnnotationConfiguration {
            val builder = MeasurementDistanceAnnotationConfiguration.builder(context)
            val iterator = configuration.keys.iterator()
            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    DEFAULT_COLOR -> builder.setDefaultColor(
                        extractColor(configuration[key] as String)
                    )

                    DEFAULT_ALPHA -> builder.setDefaultAlpha((configuration[key] as Double).toFloat())
                    DEFAULT_THICKNESS -> builder.setDefaultThickness(
                        (configuration[key] as Double).toFloat()
                    )

                    AVAILABLE_COLORS -> configuration[key]?.let { colors ->
                        builder.setAvailableColors(
                            extractColors(
                                (colors as List<*>).map { it as String })
                        )
                    }

                    MAX_ALPHA -> builder.setMaxAlpha((configuration[key] as Double).toFloat())
                    MIN_ALPHA -> builder.setMinAlpha((configuration[key] as Double).toFloat())
                    MAX_THICKNESS -> builder.setMaxThickness((configuration[key] as Double).toFloat())
                    MIN_THICKNESS -> builder.setMinThickness((configuration[key] as Double).toFloat())
                    CUSTOM_COLOR_PICKER_ENABLED -> builder.setCustomColorPickerEnabled(
                        configuration[key] as Boolean
                    )

                    PREVIEW_ENABLED -> builder.setPreviewEnabled(configuration[key] as Boolean)
                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    else -> {
                        throw IllegalArgumentException("Unknown annotation configuration key: $key")
                    }
                }
            }
            return builder.build()
        }


        private fun parseMeasurementPerimeterAnnotationConfiguration(
            context: Context,
            configuration: Map<*, *>
        ): AnnotationConfiguration {
            val builder = MeasurementPerimeterAnnotationConfiguration.builder(context)
            val iterator = configuration.keys.iterator()
            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    DEFAULT_COLOR -> builder.setDefaultColor(
                        extractColor(configuration[key] as String)
                    )

                    DEFAULT_ALPHA -> builder.setDefaultAlpha((configuration[key] as Double).toFloat())
                    DEFAULT_THICKNESS -> builder.setDefaultThickness(
                        (configuration[key] as Double).toFloat()
                    )

                    AVAILABLE_COLORS -> (configuration[key] as List<*>?)?.let { colors ->
                        builder.setAvailableColors(
                            extractColors(colors.map { it as String })
                        )
                    }

                    DEFAULT_LINE_END -> configuration[key].let { lineEndPair ->

                        builder.setDefaultLineEnds(extractLineEndPair(lineEndPair as String))
                    }

                    AVAILABLE_LINE_ENDS -> (configuration[key] as List<*>?)?.let { lineEnds ->
                        builder.setAvailableLineEnds(
                            extractLineEnds(
                                lineEnds.map { it as String })
                        )
                    }

                    MAX_ALPHA -> builder.setMaxAlpha((configuration[key] as Double).toFloat())
                    MIN_ALPHA -> builder.setMinAlpha((configuration[key] as Double).toFloat())
                    MAX_THICKNESS -> builder.setMaxThickness((configuration[key] as Double).toFloat())
                    MIN_THICKNESS -> builder.setMinThickness((configuration[key] as Double).toFloat())
                    CUSTOM_COLOR_PICKER_ENABLED -> builder.setCustomColorPickerEnabled(
                        configuration[key] as Boolean
                    )

                    PREVIEW_ENABLED -> builder.setPreviewEnabled(configuration[key] as Boolean)
                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    else -> {
                        throw IllegalArgumentException("Unknown annotation configuration key: $key")
                    }
                }
            }
            return builder.build()
        }

        private fun extractLineEndPair(lineEndPair: String): Pair<LineEndType, LineEndType> {
            val lineEnds = lineEndPair.split(",")
            if (lineEnds.size != 2) {
                throw IllegalArgumentException("Invalid line end pair: $lineEndPair")
            }
            val firstLineEnd = parseLineEnd(lineEnds[0])
            val secondLineEnd = parseLineEnd(lineEnds[0])
            return Pair(firstLineEnd, secondLineEnd)
        }

        private fun parseLineEnd(s: String): LineEndType {
            return when (s) {
                "none" -> LineEndType.NONE
                "square" -> LineEndType.SQUARE
                "circle" -> LineEndType.CIRCLE
                "openArrow" -> LineEndType.OPEN_ARROW
                "closedArrow" -> LineEndType.CLOSED_ARROW
                "butt" -> LineEndType.BUTT
                "reverseOpenArrow" -> LineEndType.REVERSE_OPEN_ARROW
                "reverseClosedArrow" -> LineEndType.REVERSE_CLOSED_ARROW
                "diamond" -> LineEndType.DIAMOND
                else -> {
                    LineEndType.NONE
                }
            }
        }

        private fun parseShapeAnnotationConfiguration(
            context: Context, configuration: Map<*, *>, annotationType: AnnotationType
        ): AnnotationConfiguration {
            val builder = ShapeAnnotationConfiguration.builder(context, annotationType)

            val iterator = configuration.keys.iterator()

            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    DEFAULT_COLOR -> builder.setDefaultColor(
                        extractColor(configuration[key] as String)
                    )

                    DEFAULT_FILL_COLOR -> builder.setDefaultFillColor(
                        extractColor(
                            configuration[key] as String
                        )
                    )

                    DEFAULT_ALPHA -> builder.setDefaultAlpha((configuration[key] as Double).toFloat())
                    DEFAULT_THICKNESS -> builder.setDefaultThickness(
                        (configuration[key] as Double).toFloat()
                    )

                    AVAILABLE_COLORS -> (configuration[key] as List<*>?)?.let { colors ->
                        builder.setAvailableColors(
                            extractColors(colors.map { it as String })
                        )
                    }

                    AVAILABLE_FILL_COLORS -> (configuration[key] as List<*>?)?.let { fillColors ->
                        builder.setAvailableFillColors(
                            extractColors(fillColors.map { it as String })
                        )
                    }

                    MAX_ALPHA -> builder.setMaxAlpha((configuration[key] as Double).toFloat())
                    MIN_ALPHA -> builder.setMinAlpha((configuration[key] as Double).toFloat())
                    MAX_THICKNESS -> builder.setMaxThickness((configuration[key] as Double).toFloat())
                    MIN_THICKNESS -> builder.setMinThickness((configuration[key] as Double).toFloat())
                    CUSTOM_COLOR_PICKER_ENABLED -> builder.setCustomColorPickerEnabled(
                        configuration[key] as Boolean
                    )

                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    PREVIEW_ENABLED -> builder.setPreviewEnabled(configuration[key] as Boolean)
                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    DEFAULT_BORDER_STYLE -> builder.setDefaultBorderStylePreset(
                        extractBorderStyles(
                            listOf(configuration[key] as String)
                        ).first()
                    )

                    AVAILABLE_BORDER_STYLES_PRESETS -> builder.setBorderStylePresets(
                        extractBorderStyles(
                            configuration[key] as List<String>
                        )
                    )

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    else -> {
                        throw IllegalArgumentException("Unknown key: $key")
                    }
                }
            }
            return builder.build()
        }

        private fun parseMarkupAnnotationConfiguration(
            context: Context, configuration: Map<*, *>, annotationType: AnnotationType
        ): AnnotationConfiguration {

            val builder = MarkupAnnotationConfiguration.builder(context, annotationType)

            val iterator = configuration.keys.iterator()

            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    DEFAULT_COLOR -> builder.setDefaultColor(
                        extractColor(configuration[key] as String)
                    )

                    DEFAULT_ALPHA -> builder.setDefaultAlpha((configuration[key] as Double).toFloat())
                    AVAILABLE_COLORS -> (configuration[key] as List<*>?)?.let { colors ->
                        builder.setAvailableColors(
                            extractColors(colors.map { it as String })
                        )
                    }

                    MAX_ALPHA -> builder.setMaxAlpha((configuration[key] as Double).toFloat())
                    MIN_ALPHA -> builder.setMinAlpha((configuration[key] as Double).toFloat())
                    CUSTOM_COLOR_PICKER_ENABLED -> builder.setCustomColorPickerEnabled(
                        configuration[key] as Boolean
                    )

                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    else -> {
                        throw IllegalArgumentException("Unknown key: $key")
                    }
                }
            }

            return builder.build()
        }

        private fun parseEraserAnnotationConfiguration(configuration: Map<*, *>): AnnotationConfiguration {
            val builder = EraserToolConfiguration.builder()
            val iterator = configuration.keys.iterator()

            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    DEFAULT_THICKNESS -> builder.setDefaultThickness(
                        (configuration[key] as Double).toFloat()
                    )

                    MAX_THICKNESS -> builder.setMaxThickness((configuration[key] as Double).toFloat())
                    MIN_THICKNESS -> builder.setMinThickness((configuration[key] as Double).toFloat())
                    PREVIEW_ENABLED -> builder.setPreviewEnabled(configuration[key] as Boolean)
                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    else -> {
                        throw IllegalArgumentException("Unknown key: $key")
                    }

                }

            }
            return builder.build()
        }

        private fun parseSoundAnnotationConfiguration(
            configuration: Map<*, *>
        ): AnnotationConfiguration {
            val builder = SoundAnnotationConfiguration.builder()
            val iterator = configuration.keys.iterator()

            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    AUDION_SAMPLING_RATE -> builder.setAudioRecordingSampleRate(
                        configuration[key] as Int
                    )

                    AUDIO_RECORDING_TIME_LIMIT -> builder.setAudioRecordingTimeLimit(
                        configuration[key] as Int
                    )

                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    else -> {
                        throw IllegalArgumentException("Unknown key: $key")
                    }
                }
            }
            return builder.build()
        }

        private fun parseFileAnnotationConfiguration(
            configuration: Map<*, *>
        ): AnnotationConfiguration {
            val builder = FileAnnotationConfiguration.builder()
            val iterator = configuration.keys.iterator()

            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    else -> {
                        throw IllegalArgumentException("Unknown key: $key")
                    }
                }
            }
            return builder.build()

        }

        private fun parseStampAnnotationConfiguration(
            context: Context, configuration: Map<*, *>
        ): AnnotationConfiguration {
            val builder = StampAnnotationConfiguration.builder(context)
            val iterator = configuration.keys.iterator()

            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    AVAILABLE_STAMP_ITEMS -> (configuration[key] as List<*>?)?.let { stampItems ->
                        builder.setAvailableStampPickerItems(
                            extractStampPickerItems(
                                stampItems.map { it as String }, context
                            )
                        )
                    }

                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    else -> {
                        throw IllegalArgumentException("Unknown key: $key")
                    }
                }
            }
            return builder.build()
        }


        private fun parseRedactAnnotationConfiguration(
            context: Context, configuration: Map<*, *>
        ): AnnotationConfiguration {
            val builder = RedactionAnnotationConfiguration.builder(context)

            val iterator = configuration.keys.iterator()

            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    DEFAULT_COLOR -> builder.setDefaultColor(
                        extractColor(
                            configuration[key] as String
                        )
                    )

                    DEFAULT_FILL_COLOR -> builder.setDefaultFillColor(
                        extractColor(
                            configuration[key] as String
                        )
                    )

                    AVAILABLE_COLORS -> (configuration[key] as List<*>?)?.let { colors ->
                        builder.setAvailableColors(
                            extractColors(
                                colors.map { it as String })
                        )
                    }

                    AVAILABLE_FILL_COLORS -> (configuration[key] as List<*>?)?.let { fillColors ->
                        builder.setAvailableFillColors(
                            extractColors(
                                fillColors.map { it as String })
                        )
                    }

                    OVERLAY_TEXT -> configuration[key].let { overlayText ->
                        builder.setDefaultOverlayText(overlayText as String)
                    }

                    REPEAT_OVERLAY_TEXT -> configuration[key].let { repeatOverlayText ->
                        builder.setDefaultRepeatOverlayTextSetting(repeatOverlayText as Boolean)
                    }

                    CUSTOM_COLOR_PICKER_ENABLED -> builder.setCustomColorPickerEnabled(
                        configuration[key] as Boolean
                    )

                    PREVIEW_ENABLED -> builder.setPreviewEnabled(configuration[key] as Boolean)
                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    else -> {
                        throw IllegalArgumentException("Unknown key: $key")
                    }

                }
            }
            return builder.build()
        }

        private fun parseNoteAnnotationConfiguration(
            context: Context, configuration: Map<*, *>
        ): AnnotationConfiguration {
            val builder = NoteAnnotationConfiguration.builder(context)

            val iterator = configuration.keys.iterator()

            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    DEFAULT_COLOR -> builder.setDefaultColor(
                        extractColor(
                            configuration[key] as String
                        )
                    )

                    AVAILABLE_COLORS -> (configuration[key] as List<*>?)?.let { colors ->
                        builder.setAvailableColors(
                            extractColors(
                                colors.map { it as String })
                        )
                    }

                    CUSTOM_COLOR_PICKER_ENABLED -> builder.setCustomColorPickerEnabled(
                        configuration[key] as Boolean
                    )

                    AVAILABLE_ICON_NAMES -> (configuration[key] as List<*>?)?.let { names ->
                        builder.setAvailableIconNames(names.map { it as String })
                    }

                    DEFAULT_ICON_NAME -> (configuration[key] as String).let {
                        builder.setDefaultIconName(
                            it
                        )
                    }

                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    else -> {
                        throw IllegalArgumentException("Unknown key: $key")
                    }
                }
            }
            return builder.build()
        }

        private fun parseLineAnnotationConfiguration(
            context: Context, configuration: Map<*, *>, type: AnnotationType, tool: AnnotationTool
        ): AnnotationConfiguration {
            val builder = LineAnnotationConfiguration.builder(context, tool)

            val iterator = configuration.keys.iterator()

            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    DEFAULT_COLOR -> builder.setDefaultColor(
                        extractColor(configuration[key] as String)
                    )

                    AVAILABLE_COLORS -> (configuration[key] as List<*>?)?.let { colors ->
                        builder.setAvailableColors(
                            extractColors(
                                colors.map { it as String })
                        )
                    }

                    DEFAULT_FILL_COLOR -> builder.setDefaultFillColor(
                        extractColor(
                            configuration[key] as String
                        )
                    )

                    AVAILABLE_FILL_COLORS -> (configuration[key] as List<*>?)?.let { fillColors ->
                        builder.setAvailableFillColors(
                            extractColors(
                                fillColors.map { it as String })
                        )
                    }

                    CUSTOM_COLOR_PICKER_ENABLED -> builder.setCustomColorPickerEnabled(
                        configuration[key] as Boolean
                    )

                    DEFAULT_THICKNESS -> builder.setDefaultThickness(
                        (configuration[key] as Double).toFloat()
                    )

                    MIN_THICKNESS -> builder.setMinThickness(
                        (configuration[key] as Double).toFloat()
                    )

                    MAX_THICKNESS -> builder.setMaxThickness(
                        (configuration[key] as Double).toFloat()
                    )

                    DEFAULT_ALPHA -> builder.setDefaultAlpha(
                        (configuration[key] as Double).toFloat()
                    )

                    MIN_ALPHA -> builder.setMinAlpha(
                        (configuration[key] as Double).toFloat()
                    )

                    MAX_ALPHA -> builder.setMaxAlpha(
                        (configuration[key] as Double).toFloat()
                    )

                    DEFAULT_LINE_END -> configuration[key].let {
                        builder.setDefaultLineEnds(
                            extractLineEndPair(it as String)
                        )
                    }

                    AVAILABLE_LINE_ENDS -> (configuration[key] as List<*>?)
                        ?.let { lineEnds ->
                            builder.setAvailableLineEnds(extractLineEnds(lineEnds.map { it as String }))
                        }

                    DEFAULT_BORDER_STYLE -> configuration[key].let {
                        builder.setDefaultBorderStylePreset(
                            extractBorderStyles(
                                listOf(it as String)
                            ).first()
                        )
                    }

                    PREVIEW_ENABLED -> builder.setPreviewEnabled(configuration[key] as Boolean)
                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    else -> {
                        throw IllegalArgumentException("Unknown key: $key")
                    }
                }
            }
            return builder.build()
        }

        private fun extractLineEnds(strings: List<String>): MutableList<LineEndType> {
            val lineEnds = mutableListOf<LineEndType>()
            strings.forEach {
                lineEnds.add(parseLineEnd(it))
            }
            return lineEnds
        }

        private fun parserFreeTextAnnotationConfiguration(
            context: Context, configuration: Map<*, *>
        ): AnnotationConfiguration {

            val builder = FreeTextAnnotationConfiguration.builder(context)
            val iterator = configuration.keys.iterator()

            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    DEFAULT_COLOR -> configuration[key].let { color ->
                        builder.setDefaultColor(
                            extractColor(color as String)
                        )
                    }

                    AVAILABLE_COLORS -> (configuration[key] as List<*>?)?.let { colors ->
                        builder.setAvailableColors(
                            extractColors(
                                colors.map { it as String })
                        )
                    }

                    DEFAULT_FILL_COLOR -> configuration[key].let { color ->
                        builder.setDefaultFillColor(
                            extractColor(color as String)
                        )
                    }

                    AVAILABLE_FILL_COLORS -> (configuration[key] as List<*>?)?.let { colors ->
                        builder.setAvailableFillColors(
                            extractColors(
                                colors.map { it as String })
                        )
                    }

                    DEFAULT_ALPHA -> builder.setDefaultAlpha(
                        (configuration[key] as Double).toFloat()
                    )

                    MIN_ALPHA -> builder.setMinAlpha(
                        (configuration[key] as Double).toFloat()
                    )

                    MAX_ALPHA -> builder.setMaxAlpha(
                        (configuration[key] as Double).toFloat()
                    )

                    CUSTOM_COLOR_PICKER_ENABLED -> builder.setCustomColorPickerEnabled(
                        configuration[key] as Boolean
                    )


                    DEFAULT_TEXT_SIZE -> builder.setDefaultTextSize(
                        (configuration[key] as Double).toFloat()
                    )

                    MAX_TEXT_SIZE -> builder.setMaxTextSize(
                        (configuration[key] as Double).toFloat()
                    )

                    MIN_TEXT_SIZE -> builder.setMinTextSize(
                        (configuration[key] as Double).toFloat()
                    )

                    DEFAULT_FONT -> configuration[key].let { font ->
                        builder.setDefaultFont(
                            extractFonts(listOf(font as String)).first()
                        )
                    }

                    AVAILABLE_FONTS -> (configuration[key] as List<*>?)?.let { fonts ->
                        builder.setAvailableFonts(
                            extractFonts(fonts.map { it as String })
                        )
                    }

                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    PREVIEW_ENABLED -> builder.setPreviewEnabled(configuration[key] as Boolean)

                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    else -> {
                        throw IllegalArgumentException("Unknown key: $key")
                    }
                }
            }

            return builder.build()
        }


        private fun parseInkAnnotationConfiguration(
            context: Context, configuration: Map<*, *>
        ): InkAnnotationConfiguration {
            val builder = InkAnnotationConfiguration.builder(context)
            val iterator = configuration.keys.iterator()

            while (iterator.hasNext()) {
                when (val key = iterator.next()) {
                    DEFAULT_THICKNESS -> builder.setDefaultThickness(
                        (configuration[key] as Double).toFloat()
                    )

                    DEFAULT_COLOR -> builder.setDefaultColor(
                        extractColor(
                            configuration[key] as String
                        )
                    )

                    DEFAULT_FILL_COLOR -> builder.setDefaultFillColor(
                        extractColor(
                            configuration[key] as String
                        )
                    )

                    DEFAULT_ALPHA -> builder.setDefaultAlpha((configuration[key] as Double).toFloat())
                    AVAILABLE_COLORS -> (configuration[key] as List<*>?)?.let { colors ->
                        builder.setAvailableColors(
                            extractColors(
                                colors.map { it as String }
                            )
                        )
                    }

                    AVAILABLE_FILL_COLORS -> (configuration[key] as List<*>?)?.let { colors ->
                        builder.setAvailableFillColors(
                            extractColors(
                                colors.map { it as String }
                            )
                        )
                    }

                    MAX_ALPHA -> builder.setMaxAlpha((configuration[key] as Double).toFloat())
                    MIN_ALPHA -> builder.setMinAlpha((configuration[key] as Double).toFloat())
                    MAX_THICKNESS -> builder.setMaxThickness((configuration[key] as Double).toFloat())
                    MIN_THICKNESS -> builder.setMinThickness((configuration[key] as Double).toFloat())
                    CUSTOM_COLOR_PICKER_ENABLED -> builder.setCustomColorPickerEnabled(
                        configuration[key] as Boolean
                    )

                    PREVIEW_ENABLED -> builder.setPreviewEnabled(configuration[key] as Boolean)
                    Z_INDEX_EDITING_ENABLED -> builder.setZIndexEditingEnabled(
                        configuration[key] as Boolean
                    )

                    FORCE_DEFAULTS -> builder.setForceDefaults(configuration[key] as Boolean)
                    SUPPORTED_PROPERTIES -> (configuration[key] as List<*>?)?.let { properties ->
                        builder.setSupportedProperties(
                            extractSupportedProperties(
                                properties.map { it as String })
                        )
                    }

                    AGGREGATION_STRATEGY -> builder.setAnnotationAggregationStrategy(
                        extractAggregationStrategy(configuration[key] as String)
                    )

                    else -> throw IllegalArgumentException("Unknown property $key")
                }
            }
            return builder.build();
        }

        private fun extractFonts(font: List<String>): MutableList<Font> {
            val fonts = mutableListOf<Font>()
            font.forEach {
                fonts.add(Font(it))
            }
            return fonts
        }

        private fun extractStampPickerItems(it: Any, context: Context): List<StampPickerItem> {
            val stampPickerItems = mutableListOf<StampPickerItem>()
            (it as ArrayList<*>).forEach { stampPickerItem ->
                val stampPickerItemString = stampPickerItem as String
                stampPickerItems.add(
                    StampPickerItem.fromTitle(context, stampPickerItemString).build()
                )
            }
            return stampPickerItems
        }

        private fun extractBorderStyles(it: List<String>): List<BorderStylePreset> {
            val borderStyles = mutableListOf<BorderStylePreset>()
            it.forEach { borderStyle ->
                when (borderStyle) {
                    "solid" -> borderStyles.add(BorderStylePreset.SOLID)
                    "cloudy" -> borderStyles.add(BorderStylePreset.CLOUDY)
                    "none" -> borderStyles.add(BorderStylePreset.NONE)
                    "dashed_1_1" -> borderStyles.add(BorderStylePreset.DASHED_1_1)
                    "dashed_1_3" -> borderStyles.add(BorderStylePreset.DASHED_1_3)
                    "dashed_3_3" -> borderStyles.add(BorderStylePreset.DASHED_3_3)
                    "dashed_6_6" -> borderStyles.add(BorderStylePreset.DASHED_6_6)
                }
            }
            return borderStyles
        }

        private fun extractSupportedProperties(properties: List<String>): EnumSet<AnnotationProperty> {
            val supportedProperties = EnumSet.noneOf(AnnotationProperty::class.java)
            properties.forEach { property ->
                when (property) {
                    "color" -> supportedProperties.add(AnnotationProperty.COLOR)
                    "fillColor" -> supportedProperties.add(AnnotationProperty.FILL_COLOR)
                    "thickness" -> supportedProperties.add(AnnotationProperty.THICKNESS)
                    "borderStyle" -> supportedProperties.add(AnnotationProperty.BORDER_STYLE)
                    "font" -> supportedProperties.add(AnnotationProperty.FONT)
                    "overlayText" -> supportedProperties.add(AnnotationProperty.OVERLAY_TEXT)
                }
            }
            return supportedProperties
        }

        private fun extractAggregationStrategy(string: String?): AnnotationAggregationStrategy {
            return when (string) {
                "automatic" -> AnnotationAggregationStrategy.AUTOMATIC
                "merge" -> AnnotationAggregationStrategy.MERGE_IF_POSSIBLE
                "separate" -> AnnotationAggregationStrategy.SEPARATE
                else -> throw IllegalArgumentException("Unknown aggregation strategy $string")
            }
        }

        private fun extractColor(colorStrings: String?): Int {
            if (colorStrings == null)
                return Color.BLUE
            return extractColors(listOf(colorStrings)).first()
        }

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
}
