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

@objc(HeadlessDocumentApiImpl)
public class HeadlessDocumentApiImpl: NSObject, HeadlessDocumentApi {

    // MARK: - Properties

    /// Registry to store opened documents by their ID
    private static var documentRegistry: [String: FlutterPdfDocument] = [:]

    /// Binary messenger for registering PdfDocumentApi instances
    private var binaryMessenger: FlutterBinaryMessenger

    // MARK: - Initialization

    @objc public init(binaryMessenger: FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger
        super.init()
    }

    // MARK: - HeadlessDocumentApi Implementation

    func openDocument(documentPath: String, options: HeadlessDocumentOpenOptions?, completion: @escaping (Result<String, Error>) -> Void) {
        // Validate document path
        guard !documentPath.isEmpty else {
            let error = NutrientApiError(
                code: "invalid_argument",
                message: "Document path cannot be empty",
                details: nil
            )
            completion(.failure(error))
            return
        }

        // Create document instance
        guard let document = PspdfkitFlutterHelper.document(fromPath: documentPath) else {
            let error = NutrientApiError(
                code: "document_load_error",
                message: "Failed to load document at path: \(documentPath)",
                details: nil
            )
            completion(.failure(error))
            return
        }

        // Handle password-protected documents
        if let password = options?.password {
            PspdfkitFlutterHelper.unlock(document: document, dictionary: ["password": password])
            // Check if the document is still locked after attempting to unlock
            if document.isLocked {
                let error = NutrientApiError(
                    code: "unlock_error",
                    message: "Failed to unlock document with provided password",
                    details: nil
                )
                completion(.failure(error))
                return
            }
        }

        // Validate document is accessible
        guard document.isValid else {
            let error = NutrientApiError(
                code: "document_invalid",
                message: "Document is not valid or accessible",
                details: nil
            )
            completion(.failure(error))
            return
        }

        // Generate unique document ID
        let documentId = UUID().uuidString

        // Create FlutterPdfDocument instance for headless mode with the documentId
        // so closeDocument can properly clean up
        let flutterPdfDocument = FlutterPdfDocument(document: document, documentId: documentId)

        // Register the document in our registry
        HeadlessDocumentApiImpl.documentRegistry[documentId] = flutterPdfDocument

        // Register PdfDocumentApi with the document ID as channel suffix
        // and store the binaryMessenger for cleanup in closeDocument
        flutterPdfDocument.register(binaryMessenger: binaryMessenger)

        // Return the document ID
        completion(.success(documentId))
    }

    // MARK: - Document Registry Management

    /// Closes and removes a document from the registry
    @objc public static func closeDocument(documentId: String) {
        documentRegistry.removeValue(forKey: documentId)
    }

    /// Gets a document from the registry
    @objc public static func getDocument(documentId: String) -> FlutterPdfDocument? {
        return documentRegistry[documentId]
    }

    /// Clears all documents from the registry
    @objc public static func clearAllDocuments() {
        documentRegistry.removeAll()
    }

    // MARK: - Registration

    @objc public func register(binaryMessenger: FlutterBinaryMessenger) {
        HeadlessDocumentApiSetup.setUp(binaryMessenger: binaryMessenger, api: self, messageChannelSuffix: "nutrient")
    }

    @objc public func unregister(binaryMessenger: FlutterBinaryMessenger) {
        HeadlessDocumentApiSetup.setUp(binaryMessenger: binaryMessenger, api: nil, messageChannelSuffix: "nutrient")
    }
}
