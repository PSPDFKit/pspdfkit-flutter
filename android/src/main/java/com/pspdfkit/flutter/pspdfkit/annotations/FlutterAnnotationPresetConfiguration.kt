package com.pspdfkit.flutter.pspdfkit.annotations

import com.pspdfkit.annotations.AnnotationType
import com.pspdfkit.annotations.configuration.AnnotationConfiguration
import com.pspdfkit.ui.special_mode.controller.AnnotationTool
import com.pspdfkit.ui.special_mode.controller.AnnotationToolVariant

data class FlutterAnnotationPresetConfiguration(val type: AnnotationType?,
                                                val annotationTool:AnnotationTool?,
                                                val variant: AnnotationToolVariant?,
                                                val configuration:AnnotationConfiguration )
