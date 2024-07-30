//
//  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation

@objc(FlutterPdfDocument)
public class FlutterPdfDocument: NSObject {
    
    // MARK: - Properties
    var document: Document?
    var messenger: FlutterBinaryMessenger?
    var chanel: FlutterMethodChannel?
    
  @objc public init(document: Document, messenger: FlutterBinaryMessenger) {
        super.init()
        self.document = document
        self.messenger = messenger
        self.chanel = FlutterMethodChannel(name: "com.pspdfkit.document."+document.uid, binaryMessenger: messenger)
        self.chanel?.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self.handleMethodCall(call: call, result: result)
          })

    }

    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "getFormFields":
            let formFields = self.document?.formParser?.forms
            if (formFields == nil){
                result(FlutterError(code: "PdfDocumentError", message: "No form fields found", details: nil))
                return
            }
            let formFieldJson = FormHelper.convertFormFields(formFields: formFields!)
            result(formFieldJson)
            break
            case "getPageInfo":
                if let pageIndex = (call.arguments as? [String: Any])?["pageIndex"] as? Int {
                    let finalPageIndex = PageIndex(pageIndex)
                    let pageInfo = self.document?.pageInfoForPage(at: finalPageIndex)
                    let pageInfoDictionary: [String: Any?] = [
                        "width": pageInfo?.size.width,
                        "height": pageInfo?.size.height,
                        "rotation": pageInfo?.savedRotation.rawValue,
                        "index": pageIndex,
                        "label": document?.pageLabelForPage(at: PageIndex(pageIndex), substituteWithPlainLabel: false)
                    ]
                    result(pageInfoDictionary)
                } else {
                    result(FlutterError(code: "InvalidArgument", message: "Invalid page index", details: nil))
                }
            break
            case "exportPdf":
                do {
                    let filePath = self.document?.fileURL?.path
                    if ((filePath) == nil){
                        result(FlutterError(code: "", message: "", details:nil))
                    }
                    let data = try Data(contentsOf: URL(fileURLWithPath: filePath!))
                    let byteArray = data.map { $0 }
                    result(byteArray)
                } catch let error {
                    result(FlutterError(code: "PdfDocumentError", message: error.localizedDescription, details: nil))
                }
            break
        case "save":
            break
            default:
                result(FlutterMethodNotImplemented)
            }
        }
}
