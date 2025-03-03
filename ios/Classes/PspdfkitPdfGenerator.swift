//
//  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation
import PSPDFKit.PSPDFProcessor

@objc(PspdfkitPdfGenerator)
@available(*, deprecated, message: "This class is deprecated and will be removed in a future release. Use PspdfkitApiImpl instead.")
public class PspdfkitPdfGenerator: NSObject {
    
    static let pageAdaptor: PspdfkitPageConvertor = PspdfkitPageConvertor()
    
    @objc public static func generatePdf(pages:Array<Dictionary<String, Any>>, outputUrl: URL, results:@escaping FlutterResult){
        
        let convertedPages = pageAdaptor.convert(pages: pages)
        let configuration = Processor.Configuration()
        
        for (index, page) in convertedPages.enumerated(){
            configuration.addNewPage(at: UInt(index) , configuration: page)
        }
        // Save to a new PDF file.
        do {
            try Processor(configuration: configuration, securityOptions: nil).write(toFileURL: outputUrl)
            results(outputUrl.relativePath);
        } catch {
            results(FlutterError(code: "PspdfkitError", message: error.localizedDescription,details: nil))
        }
    }
}
