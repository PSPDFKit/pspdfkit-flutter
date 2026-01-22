//
//  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation
import PSPDFKit

/// A class representing an iOS annotation tool with its optional variant.
class AnnotationToolWithVariant {
    let annotationTool: PSPDFKit.Annotation.Tool
    let variant: PSPDFKit.Annotation.Variant?
    
    init(annotationTool: PSPDFKit.Annotation.Tool, variant: PSPDFKit.Annotation.Variant? = nil) {
        self.annotationTool = annotationTool
        self.variant = variant
    }
}

/// Helper class for annotation-related operations, including mapping between Flutter and iOS annotation tools.
class AnnotationHelper {
    
    /**
     Maps a Flutter AnnotationTool name to the corresponding iOS AnnotationToolWithVariant.
     
     - Parameter flutterToolName: The name of the Flutter AnnotationTool enum value.
     - Returns: The corresponding iOS AnnotationToolWithVariant, or nil if no mapping exists.
     */
    static func getIOSAnnotationToolWithVariantFromFlutterName(_ flutterToolName: AnnotationTool?) -> AnnotationToolWithVariant? {
        guard let flutterTool = flutterToolName else { return nil }
        
        // Convert the Flutter tool name to the corresponding iOS tool with variant
        switch flutterTool {
        // Ink tools with variants
        case AnnotationTool.inkPen:
            return AnnotationToolWithVariant(annotationTool: .ink, variant: PSPDFKit.Annotation.Variant.inkPen)
        case AnnotationTool.inkMagic:
            return AnnotationToolWithVariant(annotationTool: .ink, variant: PSPDFKit.Annotation.Variant.inkMagic)
        case AnnotationTool.inkHighlighter:
            return AnnotationToolWithVariant(annotationTool: .ink, variant: PSPDFKit.Annotation.Variant.inkHighlighter)
            
        // Free text tools
        case AnnotationTool.freeText:
            return AnnotationToolWithVariant(annotationTool: .freeText)
        case AnnotationTool.freeTextCallOut:
            return AnnotationToolWithVariant(annotationTool: .freeText, variant: PSPDFKit.Annotation.Variant.freeTextCallout)
            
        // Shape tools
        case AnnotationTool.stamp:
            return AnnotationToolWithVariant(annotationTool: .stamp)
        case AnnotationTool.image:
            return AnnotationToolWithVariant(annotationTool: .image)
            
        // Text markup tools
        case AnnotationTool.highlight:
            return AnnotationToolWithVariant(annotationTool: .highlight)
        case AnnotationTool.underline:
            return AnnotationToolWithVariant(annotationTool: .underline)
        case AnnotationTool.squiggly:
            return AnnotationToolWithVariant(annotationTool: .squiggly)
        case AnnotationTool.strikeOut:
            return AnnotationToolWithVariant(annotationTool: .strikeOut)
            
        // Line tools
        case AnnotationTool.line:
            return AnnotationToolWithVariant(annotationTool: .line)
        case AnnotationTool.arrow:
            return AnnotationToolWithVariant(annotationTool: .line, variant: PSPDFKit.Annotation.Variant.lineArrow)
            
        // Shape tools
        case AnnotationTool.square:
            return AnnotationToolWithVariant(annotationTool: .square)
        case AnnotationTool.circle:
            return AnnotationToolWithVariant(annotationTool: .circle)
        case AnnotationTool.polygon:
            return AnnotationToolWithVariant(annotationTool: .polygon)
        case AnnotationTool.polyline:
            return AnnotationToolWithVariant(annotationTool: .polyLine)
            
        // Other tools
        case AnnotationTool.eraser:
            return AnnotationToolWithVariant(annotationTool: .eraser)
        case AnnotationTool.cloudy:
            return AnnotationToolWithVariant(annotationTool: .square, variant: PSPDFKit.Annotation.Variant.polygonCloud)
        case AnnotationTool.note:
            return AnnotationToolWithVariant(annotationTool: .note)
        case AnnotationTool.sound:
            return AnnotationToolWithVariant(annotationTool: .sound)
        case AnnotationTool.signature:
            return AnnotationToolWithVariant(annotationTool: .signature)
        case AnnotationTool.redaction:
            return AnnotationToolWithVariant(annotationTool: .redaction)
            
        // Measurement tools
        case AnnotationTool.measurementAreaRect:
            return AnnotationToolWithVariant(annotationTool: .square, variant: PSPDFKit.Annotation.Variant.rectangularAreaMeasurement)
        case AnnotationTool.measurementAreaPolygon:
            return AnnotationToolWithVariant(annotationTool: .polygon, variant: PSPDFKit.Annotation.Variant.polygonalAreaMeasurement)
        case AnnotationTool.measurementAreaEllipse:
            return AnnotationToolWithVariant(annotationTool: .circle, variant: PSPDFKit.Annotation.Variant.ellipticalAreaMeasurement)
        case AnnotationTool.measurementPerimeter:
            return AnnotationToolWithVariant(annotationTool: .polyLine, variant: PSPDFKit.Annotation.Variant.perimeterMeasurement)
        case AnnotationTool.measurementDistance:
            return AnnotationToolWithVariant(annotationTool: .line, variant: PSPDFKit.Annotation.Variant.distanceMeasurement)
        // Additional supported tools
        case AnnotationTool.caret:
            return AnnotationToolWithVariant(annotationTool: .caret)
        case AnnotationTool.richMedia:
            return AnnotationToolWithVariant(annotationTool: .richMedia)
        case AnnotationTool.screen:
            return AnnotationToolWithVariant(annotationTool: .screen)
        case AnnotationTool.file:
            return AnnotationToolWithVariant(annotationTool: .file)
        case AnnotationTool.widget:
            return AnnotationToolWithVariant(annotationTool: .widget)
        case AnnotationTool.stampImage:
            return AnnotationToolWithVariant(annotationTool: .stamp)
        case AnnotationTool.link:
            return AnnotationToolWithVariant(annotationTool: .link)
        }
    }

    /**
     For backward compatibility - returns just the AnnotationTool without variant.
     
     - Parameter flutterToolName: The name of the Flutter AnnotationTool enum value.
     - Returns: The corresponding iOS AnnotationTool, or nil if no mapping exists.
     */
    static func getIOSAnnotationToolFromFlutterName(_ flutterToolName: AnnotationTool?) -> PSPDFKit.Annotation.Tool? {
        return getIOSAnnotationToolWithVariantFromFlutterName(flutterToolName)?.annotationTool
    }
}
