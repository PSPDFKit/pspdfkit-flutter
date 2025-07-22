//
//  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation

@objc(FlutterPdfDocument)
public class FlutterPdfDocument: NSObject, PdfDocumentApi {
    
    // MARK: - Properties
    var document: Document?
    var pdfViewController: PDFViewController?
    
    @objc public init(viewController: PDFViewController) {
        super.init()
        self.document = viewController.document
        self.pdfViewController = viewController
    }
    
    func getPageInfo(pageIndex: Int64, completion: @escaping (Result<PageInfo, any Error>) -> Void) {
        let info = self.document?.pageInfoForPage(at: PageIndex(pageIndex))
        if (info == nil){
            completion(.failure(NutrientApiError(code: "Error while getting page info.", message: "Page info is nil", details: "")))
            return
        }
        let pageInfo: PageInfo =  PageInfo(pageIndex: pageIndex, height: info!.size.height, width: info!.size.width, rotation: Int64(info!.savedRotation.rawValue), label: document?.pageLabelForPage(at: PageIndex(pageIndex), substituteWithPlainLabel:false) ?? "")
        completion(.success(pageInfo))
    }
    
    func exportPdf(options: DocumentSaveOptions?, completion: @escaping (Result<FlutterStandardTypedData, any Error>) -> Void) {
        do {
            let filePath = self.document?.fileURL?.path
            if ((filePath) == nil){
                completion(.failure(NutrientApiError(code: "Error while exporting document.", message: "Filed path is null", details: "")))
            }
            
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath!))
            let flutterStandardTypedData = FlutterStandardTypedData(bytes: data)
            
            completion(.success(flutterStandardTypedData))
        } catch let error {
            completion(.failure(NutrientApiError(code: "Error while exporting document.", message: error.localizedDescription, details: "")))
        }
    }
    
    func getFormFields(completion: @escaping (Result<[[String : Any?]], any Error>) -> Void) {
        do {
            guard let document else {
                let errorMessage = "Error while getting form field value for fields"
                completion(.failure(NutrientApiError(code: "", message: errorMessage, details: nil)))
                return
            }
            let value = try PspdfkitFlutterHelper.getFormFields(for: document)
            completion(.success(value))
        } catch let error {
            let errorMessage = "Error while getting form field value for fields \(error.localizedDescription)"
            completion(.failure(NutrientApiError(code: "", message: errorMessage, details: nil)))
        }
    }
    
    func getFormField(fieldName: String, completion: @escaping (Result<[String : Any?], any Error>) -> Void) {
        do {
            guard let document else {
                let errorMessage = "Error while getting form field value for fields"
                completion(.failure(NutrientApiError(code: "", message: errorMessage, details: nil)))
                return
            }

            let value = try PspdfkitFlutterHelper.getFormFields(for: document)
            let formField = value.first(where: { $0["name"] as? String == fieldName })

            if formField == nil {
                let errorMessage = "Error while getting form field value for fields"
                completion(.failure(NutrientApiError(code: "", message: errorMessage, details: nil)))
            }

            completion(.success(formField!))
        } catch let error {
            let errorMessage = "Error while getting form field value for fields \(error.localizedDescription)"
            completion(.failure(NutrientApiError(code: "", message: errorMessage, details: nil)))
        }
    }
    
    func setFormFieldValue(value: String, fullyQualifiedName: String, completion: @escaping (Result<Bool?, any Error>) -> Void) {
        do {
            if document == nil {
                let error = NutrientApiError(code: "", message: "Error while setting form field value for field name: \(fullyQualifiedName)", details: nil)
                completion(.failure(error))
                return
            }
            let success = try PspdfkitFlutterHelper.setFormFieldValue(value, forFieldWithFullyQualifiedName: fullyQualifiedName, for: document!)
            completion(.success(success))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func getFormFieldValue(fullyQualifiedName: String, completion: @escaping (Result<String?, any Error>) -> Void) {
        do {
            guard let document else {
                completion(.failure(NutrientApiError(code: "", message: "Error while getting form field value for field name: \(fullyQualifiedName)", details: nil)))
                return
            }
            let vale = try PspdfkitFlutterHelper.getFormFieldValue(forFieldWithFullyQualifiedName: fullyQualifiedName, for: document)
            completion(.success("\(vale)"))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func applyInstantJson(annotationsJson: String, completion: @escaping (Result<Bool?, any Error>) -> Void) {
        do {
            if document == nil {
                let error = NutrientApiError(code: "", message: "Error while applying instant json for annotations: \(annotationsJson)", details: nil)
                completion(.failure(error))
                return
            }
            let success = try PspdfkitFlutterHelper.applyInstantJson(annotationsJson: annotationsJson, document: document!)
            pdfViewController?.reloadData()
            completion(.success(success))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func exportInstantJson(completion: @escaping (Result<String?, any Error>) -> Void) {
        do {
            if document == nil {
                let error = NutrientApiError(code: "", message: "Error while exporting instant json", details: nil)
                completion(.failure(error))
                return
            }
            let json = try PspdfkitFlutterHelper.exportInstantJson(document: document!)
            completion(.success(json))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func addAnnotation(jsonAnnotation: String, attachment: Any?, completion: @escaping (Result<Bool?, any Error>) -> Void) {
        do {
            if document == nil {
                let error = NutrientApiError(code: "", message: "Error while adding annotation: \(jsonAnnotation)", details: nil)
                completion(.failure(error))
                return
            }
            let success = try PspdfkitFlutterHelper.addAnnotation(jsonAnnotation, for: document!)
            completion(.success(success))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    
    func removeAnnotation(jsonAnnotation: String, completion: @escaping (Result<Bool?, any Error>) -> Void) {
        do {
            if document == nil {
                let error = NutrientApiError(code: "", message: "Error while removing annotation: \(jsonAnnotation)", details: nil)
                completion(.failure(error))
                return
            }
            let success = try PspdfkitFlutterHelper.removeAnnotation(jsonAnnotation, for: document!)
            completion(.success(success))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func getAnnotations(pageIndex: Int64, type: String, completion: @escaping (Result<Any, any Error>) -> Void) {
        do {
            if document == nil {
                let error = NutrientApiError(code: "", message: "Error while getting annotations for page: \(pageIndex)", details: nil)
                completion(.failure(error))
                return
            }
            
            let annotations = try PspdfkitFlutterHelper.getAnnotations(forPageIndex: PageIndex(pageIndex), andType: type, for: document!)
            completion(.success(annotations))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func updateAnnotation(jsonAnnotation: String, completion: @escaping (Result<Bool?, any Error>) -> Void) {
        do {
            if document == nil {
                let error = NutrientApiError(code: "", message: "Error while updating annotation: \(jsonAnnotation)", details: nil)
                completion(.failure(error))
                return
            }
            let success = try PspdfkitFlutterHelper.updateAnnotation(with: jsonAnnotation, for: document!)
            completion(.success(success))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func getAllUnsavedAnnotations(completion: @escaping (Result<Any, any Error>) -> Void) {
        do {
            if document == nil {
                let error = NutrientApiError(code: "", message: "Error while getting all unsaved annotations", details: nil)
                completion(.failure(error))
                return
            }
            
            let annotations = try PspdfkitFlutterHelper.getAllUnsavedAnnotations(for: document!)
            completion(.success(annotations))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func importXfdf(xfdfString: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        do {
            if document == nil {
                let error = NutrientApiError(code: "", message: "Error while importing xfdf: \(xfdfString)", details: nil)
                completion(.failure(error))
                return
            }
            let success = try PspdfkitFlutterHelper.importXFDF(fromString: xfdfString, for: document!)
            completion(.success(success))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func exportXfdf(xfdfPath: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        do {
            if document == nil {
                let error = NutrientApiError(code: "", message: "Error while exporting xfdf: \(xfdfPath)", details: nil)
                completion(.failure(error))
                return
            }
            
            let bookmark = try PspdfkitFlutterHelper.exportXFDF(toPath: xfdfPath, for: document!)
            completion(.success(bookmark))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func save(outputPath: String?, options: DocumentSaveOptions?, completion: @escaping (Result<Bool, any Error>) -> Void) {
        document?.save() { Result in
            if case .success = Result {
                completion(.success(true))
            } else {
                let error = NutrientApiError(code: "", message: "Failed to save PDF document.", details:   nil )
                completion(.failure(error))
            }
        }
    }
    
    func getPageCount(completion: @escaping (Result<Int64, any Error>) -> Void) {
        if let pageCount = document?.pageCount {
               completion(.success(Int64(pageCount)))
           } else {
               let error = NutrientApiError(code: "", message: "Failed to get page count.", details:   nil )
               completion(.failure(error))
           }
    }
    
    @objc public func register( binaryMessenger: FlutterBinaryMessenger){
        PdfDocumentApiSetup.setUp(binaryMessenger: binaryMessenger, api: self, messageChannelSuffix: document!.uid)
    }
    
    @objc public func unRegister(binaryMessenger: FlutterBinaryMessenger){
        PdfDocumentApiSetup.setUp(binaryMessenger: binaryMessenger, api: nil, messageChannelSuffix: document!.uid);
    }
}

