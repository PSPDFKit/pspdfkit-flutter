//
//  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
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
    private weak var binaryMessenger: FlutterBinaryMessenger?
    /// The document ID used when registering with HeadlessDocumentApi.
    /// This may differ from document.uid when documents are opened headlessly.
    private var registeredDocumentId: String?

    @objc public init(viewController: PDFViewController) {
        super.init()
        self.document = viewController.document
        self.pdfViewController = viewController
    }

    /// Initializer for headless document mode (without a view controller)
    @objc public init(document: Document) {
        super.init()
        self.document = document
        self.pdfViewController = nil
    }

    /// Initializer for headless document mode with a specific document ID
    @objc public init(document: Document, documentId: String) {
        super.init()
        self.document = document
        self.pdfViewController = nil
        self.registeredDocumentId = documentId
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
    
    func getFormFieldsJson(completion: @escaping (Result<String, any Error>) -> Void) {
        do {
            guard let document else {
                let errorMessage = "Error while getting form fields"
                completion(.failure(NutrientApiError(code: "", message: errorMessage, details: nil)))
                return
            }
            let value = try PspdfkitFlutterHelper.getFormFields(for: document)
            let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "[]"
            completion(.success(jsonString))
        } catch let error {
            let errorMessage = "Error while getting form fields: \(error.localizedDescription)"
            completion(.failure(NutrientApiError(code: "", message: errorMessage, details: nil)))
        }
    }

    func getFormFieldJson(fieldName: String, completion: @escaping (Result<String, any Error>) -> Void) {
        do {
            guard let document else {
                let errorMessage = "Error while getting form field"
                completion(.failure(NutrientApiError(code: "", message: errorMessage, details: nil)))
                return
            }

            let value = try PspdfkitFlutterHelper.getFormFields(for: document)
            let formField = value.first(where: { $0["name"] as? String == fieldName })

            guard let formField else {
                let errorMessage = "Form field not found: \(fieldName)"
                completion(.failure(NutrientApiError(code: "", message: errorMessage, details: nil)))
                return
            }

            let jsonData = try JSONSerialization.data(withJSONObject: formField, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
            completion(.success(jsonString))
        } catch let error {
            let errorMessage = "Error while getting form field: \(error.localizedDescription)"
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
            // Pass attachment as String if provided
            let attachmentString = attachment as? String
            let success = try PspdfkitFlutterHelper.addAnnotation(jsonAnnotation, attachment: attachmentString, for: document!)
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
    
    func getAnnotationsJson(pageIndex: Int64, type: String, completion: @escaping (Result<String, any Error>) -> Void) {
        do {
            if document == nil {
                let error = NutrientApiError(code: "", message: "Error while getting annotations for page: \(pageIndex)", details: nil)
                completion(.failure(error))
                return
            }

            let annotations = try PspdfkitFlutterHelper.getAnnotations(forPageIndex: PageIndex(pageIndex), andType: type, for: document!)
            let jsonData = try JSONSerialization.data(withJSONObject: annotations, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "[]"
            completion(.success(jsonString))
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
    
    func getAllUnsavedAnnotationsJson(completion: @escaping (Result<String, any Error>) -> Void) {
        do {
            if document == nil {
                let error = NutrientApiError(code: "", message: "Error while getting all unsaved annotations", details: nil)
                completion(.failure(error))
                return
            }

            // getAllUnsavedAnnotations already returns a JSON string
            let jsonString = try PspdfkitFlutterHelper.getAllUnsavedAnnotations(for: document!) as? String ?? "{}"
            completion(.success(jsonString))
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
        guard let document = document else {
            let error = NutrientApiError(code: "", message: "Document is nil.", details: nil)
            completion(.failure(error))
            return
        }

        if let outputPath = outputPath {
            // Save to a new file at the specified path
            do {
                let outputURL = URL(fileURLWithPath: outputPath)

                // Create parent directory if it doesn't exist
                let parentDir = outputURL.deletingLastPathComponent()
                try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)

                // Use Processor to write the document with all annotations to a new file
                guard let configuration = Processor.Configuration(document: document) else {
                    throw NutrientApiError(code: "", message: "Failed to create processor configuration.", details: nil)
                }

                let processor = Processor(configuration: configuration, securityOptions: nil)
                try processor.write(toFileURL: outputURL)

                completion(.success(true))
            } catch {
                let error = NutrientApiError(code: "", message: "Failed to save PDF document to path: \(error.localizedDescription)", details: nil)
                completion(.failure(error))
            }
        } else {
            // Save in place
            document.save() { result in
                if case .success = result {
                    completion(.success(true))
                } else {
                    let error = NutrientApiError(code: "", message: "Failed to save PDF document.", details: nil)
                    completion(.failure(error))
                }
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

    func processAnnotations(type: AnnotationType, processingMode: AnnotationProcessingMode, destinationPath: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        do {
            guard let document = document, document.isValid else {
                let error = NutrientApiError(code: "", message: "PDF document not found or is invalid.", details: nil)
                completion(.failure(error))
                return
            }

            // Create writable file URL
            guard let processedDocumentURL = PspdfkitFlutterHelper.writableFileURL(withPath: destinationPath, override: true, copyIfNeeded: false) else {
                throw NutrientApiError(code: "", message: "Could not create a new PDF file at the given path.", details: nil)
            }

            // Convert annotation type and processing mode
            let annotationType = PspdfkitFlutterConverter.annotationType(from: "\(type)")
            let change = PspdfkitFlutterConverter.annotationChange(from: "\(processingMode)")

            // Create processor configuration
            guard let configuration = Processor.Configuration(document: document) else {
                throw NutrientApiError(code: "", message: "Failed to create processor configuration.", details: nil)
            }

            // Modify annotations
            configuration.modifyAnnotations(ofTypes: annotationType, change: change)

            // Create processor and write output
            let processor = Processor(configuration: configuration, securityOptions: nil)
            do {
                try processor.write(toFileURL: processedDocumentURL)
            } catch {
                throw NutrientApiError(code: "", message: "Error writing to PDF file.", details: error.localizedDescription)
            }

            completion(.success(true))
        } catch {
            completion(.failure(error))
        }
    }

    func closeDocument(completion: @escaping (Result<Bool, any Error>) -> Void) {
        guard document != nil else {
            let error = NutrientApiError(code: "", message: "Document is already closed or was never opened.", details: nil)
            completion(.failure(error))
            return
        }

        // Use the registered document ID (for headless documents) or fall back to document.uid (for viewer documents)
        let documentId = registeredDocumentId ?? document?.uid ?? ""

        // Unregister from Flutter message channels if needed
        if let messenger = binaryMessenger, !documentId.isEmpty {
            PdfDocumentApiSetup.setUp(binaryMessenger: messenger, api: nil, messageChannelSuffix: documentId)
        }

        // Clear document reference
        self.document = nil
        self.pdfViewController = nil

        // Remove from registry if this is a headless document
        if !documentId.isEmpty {
            HeadlessDocumentApiImpl.closeDocument(documentId: documentId)
        }

        // Clear the registered document ID
        self.registeredDocumentId = nil

        completion(.success(true))
    }

    // MARK: - iOS Dirty State APIs

    func iOSHasDirtyAnnotations(completion: @escaping (Result<Bool, any Error>) -> Void) {
        guard let document = document else {
            let error = NutrientApiError(code: "iOSHasDirtyAnnotationsError", message: "Document is nil.", details: nil)
            completion(.failure(error))
            return
        }

        completion(.success(document.hasDirtyAnnotations))
    }

    func iOSGetAnnotationIsDirty(pageIndex: Int64, annotationId: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        guard let document = document else {
            let error = NutrientApiError(code: "iOSGetAnnotationIsDirtyError", message: "Document is nil.", details: nil)
            completion(.failure(error))
            return
        }

        let pageIndex = Int(pageIndex)
        guard let annotations = document.annotations(at: UInt(pageIndex)) as? [Annotation] else {
            let error = NutrientApiError(code: "iOSGetAnnotationIsDirtyError", message: "Could not get annotations for page \(pageIndex).", details: nil)
            completion(.failure(error))
            return
        }

        // Find annotation by ID (name or uuid)
        guard let annotation = annotations.first(where: { $0.name == annotationId || $0.uuid == annotationId }) else {
            let error = NutrientApiError(code: "iOSGetAnnotationIsDirtyError", message: "Annotation with id '\(annotationId)' not found on page \(pageIndex).", details: nil)
            completion(.failure(error))
            return
        }

        completion(.success(annotation.isDirty))
    }

    func iOSSetAnnotationIsDirty(pageIndex: Int64, annotationId: String, isDirty: Bool, completion: @escaping (Result<Bool, any Error>) -> Void) {
        guard let document = document else {
            let error = NutrientApiError(code: "iOSSetAnnotationIsDirtyError", message: "Document is nil.", details: nil)
            completion(.failure(error))
            return
        }

        let pageIndex = Int(pageIndex)
        guard let annotations = document.annotations(at: UInt(pageIndex)) as? [Annotation] else {
            let error = NutrientApiError(code: "iOSSetAnnotationIsDirtyError", message: "Could not get annotations for page \(pageIndex).", details: nil)
            completion(.failure(error))
            return
        }

        // Find annotation by ID (name or uuid)
        guard let annotation = annotations.first(where: { $0.name == annotationId || $0.uuid == annotationId }) else {
            let error = NutrientApiError(code: "iOSSetAnnotationIsDirtyError", message: "Annotation with id '\(annotationId)' not found on page \(pageIndex).", details: nil)
            completion(.failure(error))
            return
        }

        annotation.isDirty = isDirty
        completion(.success(true))
    }

    func iOSClearNeedsSaveFlag(completion: @escaping (Result<Bool, any Error>) -> Void) {
        guard let document = document else {
            let error = NutrientApiError(code: "iOSClearNeedsSaveFlagError", message: "Document is nil.", details: nil)
            completion(.failure(error))
            return
        }

        // Clear dirty state by setting isDirty = false on all annotations
        // Note: clearNeedsSaveFlag() requires specific threading context that's not
        // available here, so we clear the dirty flag on individual annotations instead.
        for pageIndex in 0..<document.pageCount {
            if let annotations = document.annotations(at: pageIndex) as? [Annotation] {
                for annotation in annotations {
                    annotation.isDirty = false
                }
            }
        }

        completion(.success(true))
    }

    // MARK: - Android Dirty State APIs (Not supported on iOS)

    func androidHasUnsavedAnnotationChanges(completion: @escaping (Result<Bool, any Error>) -> Void) {
        let error = NutrientApiError(code: "PlatformNotSupported", message: "androidHasUnsavedAnnotationChanges is only available on Android. Use iOSHasDirtyAnnotations() on iOS.", details: nil)
        completion(.failure(error))
    }

    func androidHasUnsavedFormChanges(completion: @escaping (Result<Bool, any Error>) -> Void) {
        let error = NutrientApiError(code: "PlatformNotSupported", message: "androidHasUnsavedFormChanges is only available on Android.", details: nil)
        completion(.failure(error))
    }

    func androidHasUnsavedBookmarkChanges(completion: @escaping (Result<Bool, any Error>) -> Void) {
        let error = NutrientApiError(code: "PlatformNotSupported", message: "androidHasUnsavedBookmarkChanges is only available on Android.", details: nil)
        completion(.failure(error))
    }

    func androidGetBookmarkIsDirty(bookmarkId: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        let error = NutrientApiError(code: "PlatformNotSupported", message: "androidGetBookmarkIsDirty is only available on Android.", details: nil)
        completion(.failure(error))
    }

    func androidClearBookmarkDirtyState(bookmarkId: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        let error = NutrientApiError(code: "PlatformNotSupported", message: "androidClearBookmarkDirtyState is only available on Android.", details: nil)
        completion(.failure(error))
    }

    func androidGetFormFieldIsDirty(fullyQualifiedName: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        let error = NutrientApiError(code: "PlatformNotSupported", message: "androidGetFormFieldIsDirty is only available on Android.", details: nil)
        completion(.failure(error))
    }

    // MARK: - Web Dirty State APIs (Not supported on iOS)

    func webHasUnsavedChanges(completion: @escaping (Result<Bool, any Error>) -> Void) {
        let error = NutrientApiError(code: "PlatformNotSupported", message: "webHasUnsavedChanges is only available on Web. Use iOSHasDirtyAnnotations() on iOS.", details: nil)
        completion(.failure(error))
    }

    @objc public func register(binaryMessenger: FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger
        // Use registeredDocumentId for headless documents, otherwise use document.uid
        let channelSuffix = registeredDocumentId ?? document?.uid ?? ""
        PdfDocumentApiSetup.setUp(binaryMessenger: binaryMessenger, api: self, messageChannelSuffix: channelSuffix)
    }

    @objc public func unRegister(binaryMessenger: FlutterBinaryMessenger) {
        // Use registeredDocumentId for headless documents, otherwise use document.uid
        let channelSuffix = registeredDocumentId ?? document?.uid ?? ""
        PdfDocumentApiSetup.setUp(binaryMessenger: binaryMessenger, api: nil, messageChannelSuffix: channelSuffix)
        self.binaryMessenger = nil
    }
}

