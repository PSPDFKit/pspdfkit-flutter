//
//  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation
import PSPDFKit

extension String: Error {}

class PspdfkitPageConvertor: NSObject {
    

    func convert(pages:Array<Dictionary<String,Any>>) -> Array<PDFNewPageConfiguration> {
        return pages.map{
           try! buildPage(pageConfig: $0)
        }
    }
    
    func buildPage(pageConfig:Dictionary<String, Any>) throws -> PDFNewPageConfiguration {
      
        var pageTemplate:PageTemplate?
        var imagePage: ProcessorItem?
        
        switch pageConfig["type"] as! String {
        case "pattern":
            pageTemplate = try? resolvePattern(patternConfig: pageConfig["pattern"] as! Dictionary<String, Any>)
            break
        case "imagePage":
            let imageConfig = pageConfig["imagePage"] as! Dictionary<String,Any>
            let imagepath = URL(string:imageConfig["imageUri"] as! String)!
            let image: UIImage = UIImage(contentsOfFile:imagepath.path)!
            pageTemplate = PageTemplate(pageType: .emptyPage, identifier: nil)
            imagePage =  ProcessorItem(image: image, jpegCompressionQuality: 0.7){ builder in
               
                if(imageConfig["zOrder"] != nil){
                    builder.zPosition = self.resolveZPosiiton(position: imageConfig["zOrder"] as! String)
                }
                
                if(imageConfig["position"] != nil){
                    builder.alignment = self.resolveAlignment(alignmentConfig: imageConfig["position"] as! String)
                }
            }
            break
        case "pdfPage":
            let documentConfig = pageConfig["pdfPage"] as! Dictionary<String, Any>
            let document = Document(url: (URL(string: documentConfig["documentUri"] as! String)!))
            let pageIndex = documentConfig["pageIndex"] as! UInt
            pageTemplate = PageTemplate(document: document, sourcePageIndex: pageIndex)
            break
        default:
            throw "Error: Invalid page type"
        }
        
        if (pageTemplate != nil){
            return PDFNewPageConfiguration(pageTemplate:pageTemplate!){ builder in
                builder.pageSize = self.resolvePageSize(pageSizeConfig: pageConfig["pageSize"] as! Array<Int>)
            
                // When it's an image page, the [imagePage] will not be nil.
                if(imagePage != nil){
                    builder.item = imagePage
                }
                
                if(pageConfig["backgroundColor"] != nil){
                // TODO: Convert color integer to UIColor.
                }
                
                if(pageConfig["margin"] != nil){
                    builder.pageMargins = self.resolvePageMargin(marginsConfig: pageConfig["margins"] as! Array<Int>)
                }
                
                if(pageConfig["rotation"] != nil){
                    builder.pageRotation = Rotation(rawValue: UInt(pageConfig["rotation"] as! Int))!
                }
            }
        }
        throw "Error: Failed to parse PDF page."
       
        }
        
        func resolvePageSize(pageSizeConfig:Array<Int>) -> CGSize {
            let pageSize =  CGSize(width: pageSizeConfig[0], height: pageSizeConfig[1])
            return pageSize;
        }
    
    func resolveZPosiiton(position:String) -> ProcessorItem.ZPosition {
        switch position{
        case "FOREGROUND":
            return ProcessorItem.ZPosition.foreground
        case "BACKGROUND":
            return ProcessorItem.ZPosition.background
        default:
            return ProcessorItem.ZPosition.foreground
        }
    }
        
    func resolvePageMargin(marginsConfig:Array<Int>) -> UIEdgeInsets {
        return UIEdgeInsets(top: CGFloat(marginsConfig[0]), left: CGFloat(marginsConfig[1]),
                            bottom: CGFloat(marginsConfig[2]), right: CGFloat(marginsConfig[3]))
    }
    
    private func resolvePattern(patternConfig:Dictionary<String, Any>) throws -> PageTemplate {
        let pattern = patternConfig["pattern"] as? String?
        let patterDocument = patternConfig["patternDocument"] as? String?
        let pageIndex = patternConfig["pageIndex"] as! Int
//            If a tiled document URI was provided, create template from that.
        if(patterDocument != nil){
            let patterDocumentUri = URL(string: patterDocument!!)
            return PageTemplate(tiledPatternFrom: Document(url: patterDocumentUri!), sourcePageIndex: UInt(pageIndex))
//            Otherwise look for a predefined pattern.
        }else if (pattern != nil){
            switch pattern {
            case "BLANK":
                return PageTemplate(pageType:.emptyPage, identifier: .blank)
            case "LINES_5MM":
                return PageTemplate(pageType: .tiledPatternPage, identifier: .lines5mm)
            case "LINES_7MM":
                return PageTemplate(pageType: .tiledPatternPage, identifier: .lines7mm)
            case "DOTS_5MM":
                return PageTemplate(pageType: .tiledPatternPage, identifier: .dot5mm)
            case "GRID_5MM":
                return PageTemplate(pageType: .tiledPatternPage, identifier: .grid5mm)
            default:
                throw "PSPDFKitError: Invalid page pattern!"
            }
        }
        throw "PSPDFKitError: Invalid page pattern!"
    }
    
    func resolveAlignment(alignmentConfig:String) -> RectAlignment {
        switch alignmentConfig{
        case "TOP":
            return RectAlignment.top
        case "BOTTOM":
            return RectAlignment.bottom
        case "LEFT":
            return RectAlignment.left
        case "RIGHT":
            return RectAlignment.right
        case "CENTER":
            return RectAlignment.center
        case "TOP_LEFT":
            return RectAlignment.topLeft
        case "TOP_RIGHT":
            return RectAlignment.topRight
        case "BOTTOM_LEFT":
            return RectAlignment.bottomLeft
        case "BOTTOM_RIGHT":
            return RectAlignment.bottomRight
        default:
           return RectAlignment.center
        }
    }
}
    

