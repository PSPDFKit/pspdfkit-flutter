//
//  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation
import PSPDFKit.PSPDFProcessor

@objc(PspdfkitHtmlPdfConvertor)
public class PspdfkitHtmlPdfConvertor: NSObject {
    
    @objc public static func generateFromHtmlString(html: String, outputFileURL: URL, convertionOptions: Dictionary<String,Any>?, results:@escaping FlutterResult) {
        
        var options:[String: Any] = [:]
        
        if(convertionOptions?["documentTitle"] != nil){
            options[PSPDFProcessorDocumentTitleKey] = convertionOptions?["documentTitle"]
        }
        
        if(convertionOptions?["numberOfPages"] != nil){
            options[PSPDFProcessorNumberOfPagesKey] = convertionOptions?["numberOfPages"]
        }
        
        options  = options as [String: Any]
        
        Processor.generatePDF(fromHTMLString: html,outputFileURL: outputFileURL, options: options) { outputURL, error in
            if let outputURL = outputURL {
                results(outputURL.relativePath);
            } else if let error = error {
                results(FlutterError(code: "PspdfkitError", message: error.localizedDescription,details: nil))
            }
        }
    }
    
    @objc public static func generateFromHtmlURL(htmlURL: URL, outputFileURL: URL, convertionOptions: Dictionary<String,Any>?, results:@escaping FlutterResult) {
        
        let options = [PSPDFProcessorNumberOfPagesKey: 1, PSPDFProcessorDocumentTitleKey: "Generated PDF"] as [String: Any]
        Processor.generatePDF(from:htmlURL,outputFileURL: outputFileURL, options: options) { outputURL, error in
            if let outputURL = outputURL {
                results(outputURL.relativePath);
            } else if let error = error {
                results(FlutterError(code: "PspdfkitError", message: error.localizedDescription,details: nil))
            }
        }
    }
}
