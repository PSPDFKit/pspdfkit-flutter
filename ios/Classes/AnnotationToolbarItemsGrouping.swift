//
//  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

@objc(AnnotationToolbarItemsGrouping)
public class AnnotationToolbarItemsGrouping: NSObject  {
     
     static let annotationLink = "link"
     static let annotationStrikeOut = "strikeout"
     static let annotationUnderline = "underline"
     static let annotationSquiggly = "squiggly"
     static let annotationNote = "note"
     static let annotationFreeText = "freeText"
     static let annotationInk = "ink"
     static let annotationLine = "line"
     static let annotationSquare = "square"
     static let annotationCircle = "circle"
     static let annotationPolygon = "polygon"
     static let annotationPolyLine = "polyline"
     static let annotationSignature = "signature"
     static let annotationStamp = "stamp"
     static let annotationEraser = "eraser"
     static let annotationSound = "sound"
     static let annotationImage = "image"
     static let annotationRedaction = "redaction"
     static let annotationDistanceMeasurement = "distance"
     static let annotationPerimeterMeasurement = "perimeter"
     static let annotationPolygonalAreaMeasurement = "areaPolygon"
     static let annotationEllipticalAreaMeasurement = "areaCircle"
     static let annotationSquareAreaMeasurement = "areaSquare"
     static let annotationInkPen = "pen"
     static let annotationInkMagic = "magicInk"
     static let annotationInkHighlighter = "highlighter"
     static let annotationLineArrow = "arrow"
     static let annotationFreeTextCallout = "freeTextCallout"
     static let annotationPolygonCloud = "cloudyPolygon"
     static let annotationTextHighlighter = "highlight"
     static let annotationWidget = "widget"
     static let annotationCaret = "caret"
     static let annotationHighlight = "highlight"
     static let annotationInstantCommentMarker = "instantCommentMarker"
     static let annotationScreen = "screen"
     static let annotationFile = "file"
     static let annotationWatermark = "watermark"
     static let annotationMultimedia = "multimedia"
     static let annotationTrapNet = "trapNet"
     static let annotationScaleCalibration = "scaleCalibration"
    
   @objc public static func convertAnnotationToolbarConfiguration(toolbarItems: NSArray) -> AnnotationToolConfiguration {
         var parsedItems: [AnnotationToolConfiguration.ToolGroup] = []
          
       for itemToParse in toolbarItems {
           if let dict = itemToParse as? [String: Any] {
               let subArray = dict["items"] as! [Any]
               var subItems: [AnnotationToolConfiguration.ToolItem] = []
               
               for subItem in subArray {
                   let annotationString = annotationStringFromName(name: subItem as! String)
                   if annotationString != nil {
                       subItems.append(AnnotationToolConfiguration.ToolItem(type: annotationString!, variant: annotationVariantStringFromName(name: subItem as! String), configurationBlock: annotationGroupItemConfigurationBlockFromName(name: subItem as! String)))
                   }
               }
               parsedItems.append(AnnotationToolConfiguration.ToolGroup(items: subItems))
           } else {
               let annotationType = annotationStringFromName(name: itemToParse as! String)
               let annotationVariant = annotationVariantStringFromName(name: itemToParse as! String)
               
               if annotationType != nil {
                   parsedItems.append(AnnotationToolConfiguration.ToolGroup(items: [AnnotationToolConfiguration.ToolItem(type: annotationType!, variant: annotationVariant, configurationBlock: annotationGroupItemConfigurationBlockFromName(name: itemToParse as? String ?? ""))]))
               }
            }
          }
         return PSPDFKit.AnnotationToolConfiguration(annotationGroups: parsedItems)
    }

        
     static func annotationStringFromName(name: String) -> Annotation.Tool? {
          //annotation tool string map.
          let nameToAnnotationStringMapping: [String: Annotation.Tool] = [
            annotationInk: .ink,
            annotationLine: .line,
            annotationSquare: .square,
            annotationCircle: .circle,
            annotationPolygon: .polygon,
            annotationPolyLine: .polyLine,
            annotationFreeText: .freeText,
            annotationNote: .note,
            annotationStamp: .stamp,
            annotationImage: .image,
            annotationSound: .sound,
            annotationLink: .link,
            annotationStrikeOut: .strikeOut,
            annotationUnderline: .underline,
            annotationSquiggly: .squiggly,
            annotationRedaction: .redaction,
            annotationEraser: .eraser,
            annotationSignature: .signature,
            annotationWidget: .widget,
            annotationFile: .file,
            annotationHighlight: .highlight,
            annotationCaret: .caret,
            annotationInstantCommentMarker: .instantCommentMarker,
            annotationMultimedia: .richMedia,
            annotationWatermark: .watermark,
            annotationScreen: .screen,
            annotationTrapNet: .trapNet,
            annotationInkPen: .ink,
            annotationInkHighlighter: .ink,
            annotationPolygonCloud: .polygon,
            annotationSquareAreaMeasurement: .square,
            annotationDistanceMeasurement: .line,
            annotationEllipticalAreaMeasurement:.circle,
            annotationLineArrow: .line,
            annotationInkMagic: .ink,
            annotationFreeTextCallout: .freeText,
            annotationPolygonalAreaMeasurement: .polygon
          ]
          return nameToAnnotationStringMapping[name]
    }
        
     static func annotationVariantStringFromName(name: String) -> Annotation.Variant? {
         let nameToAnnotationVariantStringMapping: [String: Annotation.Variant] = [
            annotationInkPen: .inkPen,
            annotationInkMagic: .inkMagic,
            annotationInkHighlighter: .inkHighlighter,
            annotationLineArrow: .lineArrow,
            annotationFreeTextCallout: .freeTextCallout,
            annotationPolygonCloud: .polygonCloud,
            annotationDistanceMeasurement: .distanceMeasurement,
            annotationPerimeterMeasurement: .perimeterMeasurement,
            annotationPolygonalAreaMeasurement: .polygonalAreaMeasurement,
            annotationEllipticalAreaMeasurement: .ellipticalAreaMeasurement,
            annotationSquareAreaMeasurement: .rectangularAreaMeasurement,
            annotationScaleCalibration: .measurementScaleCalibration,
          ]
          return nameToAnnotationVariantStringMapping[name]
        }
        
        static func annotationGroupItemConfigurationBlockFromName(name: String) -> PSPDFAnnotationGroupItemConfigurationBlock? {
          
          let measurementAnnotations = [annotationDistanceMeasurement, annotationPerimeterMeasurement, annotationPolygonalAreaMeasurement, annotationEllipticalAreaMeasurement, annotationSquareAreaMeasurement]
          
          if measurementAnnotations.contains(name) {
              return AnnotationToolConfiguration.ToolItem.measurementConfigurationBlock()
          }
          
          let lineAnnotations = [annotationLine, annotationLineArrow]
          if lineAnnotations.contains(name) {
            return AnnotationToolConfiguration.ToolItem.lineConfigurationBlock()
          }
          
          let inkAnnotations = [annotationInkPen, annotationInkMagic, annotationInkHighlighter]
          if inkAnnotations.contains(name) {
            return AnnotationToolConfiguration.ToolItem.inkConfigurationBlock()
          }
          
          let freeTextAnnotations = [annotationFreeText, annotationFreeTextCallout]
          if freeTextAnnotations.contains(name) {
            return AnnotationToolConfiguration.ToolItem.freeTextConfigurationBlock()
          }
          
          let polygonAnnotations = [annotationPolygon, annotationPolygonCloud]
          if polygonAnnotations.contains(name) {
            return AnnotationToolConfiguration.ToolItem.polygonConfigurationBlock()
          }
          
          return nil
        }
      }
