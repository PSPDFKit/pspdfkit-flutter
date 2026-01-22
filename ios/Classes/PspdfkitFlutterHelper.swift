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

// This class contains shared code.
class PspdfkitFlutterHelper: NSObject {
    
    // MARK: - Document Helpers
    
    static func document(fromPath path: String) -> Document? {
        let url: URL?
        
        if path.hasPrefix("/") {
            url = URL(fileURLWithPath: path)
        } else {
            url = Bundle.main.url(forResource: path, withExtension: nil)
        }
        
        guard let documentURL = url else {
            return nil
        }
        
        if isImageDocument(path) {
            return ImageDocument(imageURL: documentURL)
        } else {
            return Document(url: documentURL)
        }
    }
    
    static func isImageDocument(_ path: String) -> Bool {
        let fileExtension = path.split(separator: ".").last?.lowercased()
        return ["png", "jpeg", "jpg", "tiff", "tif"].contains(fileExtension)
    }
    
    // MARK: - File Helpers
    
    static func fileURL(withPath path: String) -> URL? {
        var expandedPath = path
        expandedPath = (expandedPath as NSString).expandingTildeInPath
        expandedPath = expandedPath.replacingOccurrences(of: "file:", with: "")
        if !(expandedPath as NSString).isAbsolutePath {
            let docsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            expandedPath = (docsFolder as NSString).appendingPathComponent(expandedPath, conformingTo: UTType.fileURL)
        }
        return URL(fileURLWithPath: expandedPath)
    }
    
    static func writableFileURL(withPath path: String, override: Bool, copyIfNeeded: Bool) -> URL? {
        let writableFileURL: URL
        if (path as NSString).isAbsolutePath {
            writableFileURL = URL(fileURLWithPath: path)
        } else {
            let docsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            writableFileURL = URL(fileURLWithPath: (docsFolder as NSString).appendingPathComponent(path))
        }
        
        let fileManager = FileManager.default
        if override {
            try? fileManager.removeItem(at: writableFileURL)
        }
        
        if !fileManager.fileExists(atPath: writableFileURL.path) {
            do {
                try fileManager.createDirectory(atPath: (writableFileURL.path as NSString).deletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create directory: \(error.localizedDescription)")
                return nil
            }
            
            if copyIfNeeded, let fileURL = fileURL(withPath: path), fileManager.fileExists(atPath: fileURL.path) {
                do {
                    try fileManager.copyItem(at: fileURL, to: writableFileURL)
                } catch {
                    print("Failed to copy item at URL '\(path)' with error: \(error.localizedDescription)")
                    return nil
                }
            }
        }
        return writableFileURL
    }
    
    // MARK: - Password Helper
    
    static func unlock(document: Document, dictionary: [String: Any]?) {
        guard let dictionary = dictionary, !dictionary.isEmpty else {
            return
        }
        if let password = dictionary["password"] as? String, !password.isEmpty {
            document.unlock(withPassword: password)
        }
    }
    
    // MARK: - Toolbar Customization
    
    static func setToolbarTitle(_ toolbarTitle: String?, for pdfViewController: PDFViewController) {
        guard let toolbarTitle = toolbarTitle else {
            return
        }
        pdfViewController.title = toolbarTitle
    }
    
    static func setLeftBarButtonItems(_ items: [String]?, for pdfViewController: PDFViewController) {
        guard let items = items, !items.isEmpty else {
            return
        }
        var leftItems = [UIBarButtonItem]()
        for barButtonItemString in items {
            if let barButtonItem = barButtonItem(fromString: barButtonItemString, for: pdfViewController),
               ((pdfViewController.navigationItem.rightBarButtonItems?.contains(barButtonItem)) == nil) {
                leftItems.append(barButtonItem)
            }
        }
        pdfViewController.navigationItem.setLeftBarButtonItems(leftItems, animated: false)
    }
    
    static func setRightBarButtonItems(_ items: [String]?, for pdfViewController: PDFViewController) {
        guard let items = items, !items.isEmpty else {
            return
        }
        var rightItems = [UIBarButtonItem]()
        for barButtonItemString in items {
            if let barButtonItem = barButtonItem(fromString: barButtonItemString, for: pdfViewController),
               ((pdfViewController.navigationItem.leftBarButtonItems?.contains(barButtonItem)) == nil) {
                rightItems.append(barButtonItem)
            }
        }
        pdfViewController.navigationItem.setRightBarButtonItems(rightItems, animated: false)
    }
    
    static func barButtonItem(fromString barButtonItem: String, for pdfViewController: PDFViewController) -> UIBarButtonItem? {
        switch barButtonItem {
        case "closeButtonItem":
            return pdfViewController.closeButtonItem
        case "outlineButtonItem":
            return pdfViewController.outlineButtonItem
        case "searchButtonItem":
            return pdfViewController.searchButtonItem
        case "thumbnailsButtonItem":
            return pdfViewController.thumbnailsButtonItem
        case "documentEditorButtonItem":
            return pdfViewController.documentEditorButtonItem
        case "printButtonItem":
            return pdfViewController.printButtonItem
        case "openInButtonItem":
            return pdfViewController.openInButtonItem
        case "emailButtonItem":
            return pdfViewController.emailButtonItem
        case "messageButtonItem":
            return pdfViewController.messageButtonItem
        case "annotationButtonItem":
            return pdfViewController.annotationButtonItem
        case "bookmarkButtonItem":
            return pdfViewController.bookmarkButtonItem
        case "brightnessButtonItem":
            return pdfViewController.brightnessButtonItem
        case "activityButtonItem":
            return pdfViewController.activityButtonItem
        case "settingsButtonItem":
            return pdfViewController.settingsButtonItem
        case "readerViewButtonItem":
            return pdfViewController.readerViewButtonItem
        default:
            return nil
        }
    }
    
    // MARK: - Forms
    
    static func setFormFieldValue(_ value: String, forFieldWithFullyQualifiedName fullyQualifiedName: String, for document: Document) throws -> Bool {
   
        guard !fullyQualifiedName.isEmpty else {
            throw NutrientApiError(code: "", message:"Fully qualified name may not be nil or empty." , details: nil)
        }
        
        var success = false
        for formElement in document.formParser?.forms ?? [] {
            if formElement.fullyQualifiedFieldName == fullyQualifiedName {
                if let buttonFormElement = formElement as? ButtonFormElement {
                    if value == "selected" {
                        buttonFormElement.select()
                        success = true
                    } else if value == "deselected" {
                        buttonFormElement.deselect()
                        success = true
                    }
                } else if let choiceFormElement = formElement as? ChoiceFormElement {
                    choiceFormElement.selectedIndices = IndexSet(integer: Int(value) ?? 0)
                    success = true
                } else if let textFieldFormElement = formElement as? TextFieldFormElement {
                    textFieldFormElement.contents = value
                    success = true
                } else if formElement is SignatureFormElement {
                    throw NutrientApiError(code: "", message: "Signature form elements cannot be modified.", details: nil)
                } else {
                    return false
                }
                break
            }
        }
        
        if !success {
            throw NutrientApiError(code: "", message: "Error while searching for a form element with name \(fullyQualifiedName).", details: nil)
        }
        return true
    }
    
    static func getFormFieldValue(forFieldWithFullyQualifiedName fullyQualifiedName: String, for document: Document) throws -> Any {
        guard !fullyQualifiedName.isEmpty else {
            throw NutrientApiError(code: "", message: "Fully qualified name may not be nil or empty.", details : nil)
        }
        
        for formElement in document.formParser?.forms ?? [] {
            if formElement.fullyQualifiedFieldName == fullyQualifiedName {
                if formElement.value != nil {
                    return formElement.value!
                } else {
                    throw NutrientApiError(code: "", message: "Error while searching for a form element with name \(fullyQualifiedName).", details: nil)
                }
            }
        }
        
        throw NutrientApiError(code: "", message: "Error while searching for a form element with name \(fullyQualifiedName).", details : nil)
    }
    
    static func getFormFields(for document: Document) throws -> [[String : Any]]{
        let formFields = document.formParser?.forms ?? []
        let data:[[String : Any]] = FormHelper.convertFormFields(formFields: formFields) as! [[String : Any]]
        if formFields.isEmpty {
            throw NutrientApiError(code: "", message: "No form fields found in the document.", details: nil)
        }
        return data
    }
    
    // MARK: - Annotation Processing
    
    static func processAnnotations(ofType type: String, withProcessingMode processingMode: String, andDestinationPath destinationPath: String, for pdfViewController: PDFViewController) throws -> Bool {
        let change = PspdfkitFlutterConverter.annotationChange(from: processingMode)
        guard let processedDocumentURL = writableFileURL(withPath: destinationPath, override: true, copyIfNeeded: false) else {
            throw NutrientApiError(code: "", message: "Could not create a new PDF file at the given path.", details : nil)
        }
        
        guard let document = pdfViewController.document, document.isValid else {
            throw NutrientApiError(code: "", message: "PDF document not found or is invalid.", details : nil)
        }
        
        let configuration = Processor.Configuration(document: document)
        configuration?.modifyAnnotations(ofTypes: PspdfkitFlutterConverter.annotationType(from: type), change: change)
        
        if configuration == nil {
            throw NutrientApiError(code: "", message: "Invalid annotation type.", details : nil)
        }
        
        let processor = Processor(configuration: configuration!, securityOptions: nil)
        do {
            try processor.write(toFileURL: processedDocumentURL)
        } catch {
            throw NutrientApiError(code: "", message: "Error writing to PDF file.", details : error.localizedDescription)
        }
        
        return true
    }
    
    // MARK: - Instant JSON

    static func addAnnotation(_ jsonAnnotation: Any, for document: Document) throws -> Bool {
        return try addAnnotation(jsonAnnotation, attachment: nil, for: document)
    }

    static func addAnnotation(_ jsonAnnotation: Any, attachment: String?, for document: Document) throws -> Bool {

        let data: Data?
        if let jsonString = jsonAnnotation as? String {
            data = jsonString.data(using: .utf8)
        } else if let jsonDict = jsonAnnotation as? [String: Any] {
            data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [])
        } else {
            throw NutrientApiError(code: "", message: "Invalid JSON Annotation.", details : nil)
        }

        guard let annotationData = data else {
            throw NutrientApiError(code: "", message: "Invalid JSON Annotation.", details: nil)
        }

        let documentProvider = document.documentProviders.first!

        // Handle attachment if provided
        var attachmentDataProvider: DataProviding? = nil
        if let attachmentJson = attachment,
           let attachmentData = attachmentJson.data(using: .utf8),
           let attachmentDict = try? JSONSerialization.jsonObject(with: attachmentData) as? [String: Any],
           let binary = attachmentDict["binary"] as? String,
           let binaryData = Data(base64Encoded: binary) {
            attachmentDataProvider = DataContainerProvider(data: binaryData)
        }

        let annotation: Annotation?
        if let provider = attachmentDataProvider {
            // addAnnotation(fromInstantJSON:attachmentDataProvider:) both creates and adds the annotation
            // It throws on failure, so we use try? and check for nil
            annotation = try? documentProvider.addAnnotation(fromInstantJSON: annotationData, attachmentDataProvider: provider)
            if annotation == nil {
                throw NutrientApiError(code: "", message: "Failed to add annotation with attachment.", details: nil)
            }
        } else {
            annotation = try? Annotation(fromInstantJSON: annotationData, documentProvider: documentProvider)
            if let ann = annotation {
                let success = document.add(annotations: [ann], options: nil)
                if !success {
                    throw NutrientApiError(code: "", message: "Failed to add annotation.", details: nil)
                }
            } else {
                throw NutrientApiError(code: "", message: "Failed to create annotation from JSON.", details: nil)
            }
        }

        return true
    }
    
    static func updateAnnotation (with jsonAnnotation: Any, for document: Document) throws -> Bool {
        // Remove annotation using the removeAnnotaiton method.
        var success = try removeAnnotation(jsonAnnotation, for: document)
        
        // Add the updated annotation.
        if success {
            success = try addAnnotation(jsonAnnotation, for: document)
            if success {
                return true
            }
        } else {
            throw NutrientApiError(code: "", message: "Failed to remove annotation.", details: nil)
        }
        
        return true
    }
    
    static func removeAnnotation(_ jsonAnnotation: Any, for document: Document) throws -> Bool {
        var annotationDict: [String: Any]?

        if let jsonString = jsonAnnotation as? String {
            if let jsonData = jsonString.data(using: .utf8),
               let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] {
                annotationDict = jsonDict
            }
        } else if let jsonDict = jsonAnnotation as? [String: Any] {
            annotationDict = jsonDict
        }

        guard let dict = annotationDict else {
            throw NutrientApiError(code: "", message: "Invalid annotation data.", details: nil)
        }

        // Try to get identifier information
        // "name" is the user-defined name
        // "id" is the Instant JSON identifier (maps to annotation's uuid or internal id)
        let name = dict["name"] as? String
        let instantId = dict["id"] as? String

        if name == nil && instantId == nil {
            throw NutrientApiError(code: "", message: "Annotation has no identifier (name or id).", details: nil)
        }

        let allAnnotations = document.allAnnotations(of: .all).values.flatMap { $0 }

        // Try to find the annotation using multiple strategies:
        // 1. First try by name (most reliable for user-created annotations)
        // 2. Then try by uuid property
        // 3. Finally try by matching the Instant JSON id
        var foundAnnotation: Annotation?

        if let name = name {
            foundAnnotation = allAnnotations.first { $0.name == name }
        }

        if foundAnnotation == nil, let instantId = instantId {
            // Try matching by uuid property
            foundAnnotation = allAnnotations.first { $0.uuid == instantId }

            // If still not found, try matching by the id in the annotation's Instant JSON
            if foundAnnotation == nil {
                foundAnnotation = allAnnotations.first { ann in
                    do {
                        let jsonData = try ann.generateInstantJSON()
                        if let annJson = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                           let annId = annJson["id"] as? String {
                            return annId == instantId
                        }
                    } catch {
                        // Ignore errors getting Instant JSON
                    }
                    return false
                }
            }
        }

        guard let annotation = foundAnnotation else {
            return false // Annotation not found, but not an error
        }

        let success = document.remove(annotations: [annotation], options: nil)
        return success
    }
    
    static func getAnnotations(forPageIndex pageIndex: PageIndex, andType typeString: String, for document: Document) throws -> Any {
        let type = annotationType(from: typeString)
        let annotations = document.annotations(at: pageIndex, type: type)
        let annotationsJSON = PspdfkitFlutterConverter.instantJSON(from: annotations)
        
        if  annotationsJSON != nil {
            return annotationsJSON
        } else {
            throw NutrientApiError(code:"", message: "Failed to get annotations.", details:nil)
        }
    }
    
    static func getAllUnsavedAnnotations(for document: Document) throws -> Any {
        let documentProvider = document.documentProviders.first!
        let data = try document.generateInstantJSON(from: documentProvider, version: .v2)
        let annotationsJSONString = String(data: data, encoding: .utf8)!
        return annotationsJSONString
    }
    
    // MARK: - XFDF
    
    static func importXFDF(fromString stringData: String, for document: Document) throws -> Bool {
        // convert string into a temporary file.
        let fileURL = try stringDataToFile(stringData)
        
        let dataProvider = FileDataProvider(fileURL: fileURL)
        let parser = XFDFParser(dataProvider: dataProvider, documentProvider: document.documentProviders[0])
        
        do {
            try parser.parse()
            let annotations = parser.annotations
            document.add(annotations: annotations, options: nil)
            // clean up temp file.
            _ = try? FileManager.default.removeItem(at: fileURL)
            return true
        } catch {
            throw NutrientApiError(code: "", message: "Error while parsing XFDF file.", details: error.localizedDescription )
        }
    }
    
    static func exportXFDF(toPath path: String, for document: Document)throws -> Bool {
        guard let fileURL = writableFileURL(withPath: path, override: true, copyIfNeeded: false) else {
            throw NutrientApiError(code: "", message: "Could not create a new XFDF file at the given path.", details: nil)
        }
        
        var annotations = [Annotation]()
        for pageAnnotations in document.allAnnotations(of: .all).values {
            annotations.append(contentsOf: pageAnnotations)
        }
        
        do {
            let dataSink = try FileDataSink(fileURL: fileURL, options: [])
            try XFDFWriter().write(annotations, to: dataSink, documentProvider: document.documentProviders[0])
        } catch {
            throw NutrientApiError(code: "", message: "Error while exporting XFDF file.", details: error.localizedDescription)
        }
        
        return true
    }
    
    static func applyInstantJson(annotationsJson: String, document: Document) throws -> Bool {
        guard let jsonData = annotationsJson.data(using: .utf8) else {
            print("Invalid JSON data.")
            throw NutrientApiError(code: "", message: "Invalid JSON data.", details : nil)
        }
        
        let jsonContainer = DataContainerProvider(data: jsonData)
        do {
            try document.applyInstantJSON(fromDataProvider: jsonContainer, to: document.documentProviders.first!, lenient: false)
            return true
        } catch {
            print("Error while importing document Instant JSON: \(error.localizedDescription)")
            throw NutrientApiError(code: "", message: "Error while importing document Instant JSON.", details: error.localizedDescription)
        }
    }
    
    static func exportInstantJson(document: Document) throws -> String  {
        do {
            let data = try document.generateInstantJSON(from: document.documentProviders.first!)
            if let annotationsJson = String(data: data, encoding: .utf8) {
                return annotationsJson
            } else {
                throw NutrientApiError(code: "", message: "Error while exporting document Instant JSON.", details: nil)
            }
        } catch {
            throw NutrientApiError(code: "", message: "Error while exporting document Instant JSON.", details: error.localizedDescription)
        }
    }
    
    static func annotationType(from typeString: String) -> Annotation.Type {
        switch typeString {
            
        // Basic annotations
        case "pspdfkit/ink":
            return InkAnnotation.self
        case "pspdfkit/link":
            return LinkAnnotation.self
        case "pspdfkit/note":
            return NoteAnnotation.self
        case "pspdfkit/text":
            return FreeTextAnnotation.self
            
        // Markup annotations
        case "pspdfkit/markup/highlight":
            return HighlightAnnotation.self
        case "pspdfkit/markup/squiggly":
            return SquigglyAnnotation.self
        case "pspdfkit/markup/strikeout":
            return StrikeOutAnnotation.self
        case "pspdfkit/markup/underline":
            return UnderlineAnnotation.self
        case "pspdfkit/markup/redaction":
            return RedactionAnnotation.self
            
        // Shape annotations
        case "pspdfkit/shape/ellipse":
            return CircleAnnotation.self
        case "pspdfkit/shape/line":
            return LineAnnotation.self
        case "pspdfkit/shape/polygon":
            return PolygonAnnotation.self
        case "pspdfkit/shape/polyline":
            return PolyLineAnnotation.self
        case "pspdfkit/shape/rectangle":
            return SquareAnnotation.self
            
        // Media annotations
        case "pspdfkit/image":
            return StampAnnotation.self
        case "pspdfkit/sound":
            return SoundAnnotation.self
        case "pspdfkit/screen":
            return ScreenAnnotation.self
        case "pspdfkit/3d":
            return Annotation.self
            
        // File annotations
        case "pspdfkit/file":
            return FileAnnotation.self
            
        // Other annotations
        case "pspdfkit/stamp":
            return StampAnnotation.self
        case "pspdfkit/caret":
            return CaretAnnotation.self
        case "pspdfkit/popup":
            return PopupAnnotation.self
        case "pspdfkit/widget":
            return WidgetAnnotation.self
        case "pspdfkit/watermark":
            return Annotation.self
        case "pspdfkit/media":
            return   RichMediaAnnotation.self
            
        // Special types
        case "pspdfkit/none":
            return Annotation.self
        case "pspdfkit/undefined":
            return Annotation.self
        case "pspdfkit/all", "all":
            return Annotation.self
        
            
        // Fallback
        default:
            return Annotation.self
        }
        
    }
    
    private static func stringDataToFile(_ stringData: String) throws -> URL {
        do {
            let stringData = stringData.data(using: .utf8)!
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.txt")
            try stringData.write(to: fileURL)
            return fileURL
        } catch {
            throw NutrientApiError(code: "PSPDFKIT_ERROR_FILE_WRITE", message: "Failed to write temporary file", details: nil)
        }
    }
    
}
