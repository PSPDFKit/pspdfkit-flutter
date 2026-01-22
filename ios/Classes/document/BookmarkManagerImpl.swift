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
import Flutter

/// Implementation of the BookmarkManagerApi for managing PDF bookmarks on iOS.
///
/// This class bridges the Flutter bookmark API to the PSPDFKit iOS SDK's
/// bookmark functionality. It supports adding, removing, updating, and querying bookmarks.
@objc(BookmarkManagerImpl)
public class BookmarkManagerImpl: NSObject, BookmarkManagerApi {

    // MARK: - Properties
    private var document: Document?
    private let documentId: String
    private let binaryMessenger: FlutterBinaryMessenger
    private let queue = DispatchQueue(label: "com.pspdfkit.bookmark-manager", qos: .userInitiated)

    // MARK: - Initialization
    init(documentId: String, binaryMessenger: FlutterBinaryMessenger) {
        self.documentId = documentId
        self.binaryMessenger = binaryMessenger
        super.init()
    }

    // MARK: - BookmarkManagerApi Implementation

    func initialize(documentId: String) throws {
        guard let doc = AnnotationManagerImpl.getDocument(withId: documentId) else {
            throw BookmarkManagerError.documentNotFound(documentId)
        }
        self.document = doc
    }

    func getBookmarks(completion: @escaping (Result<[Bookmark], Error>) -> Void) {
        queue.async {
            guard let document = self.document else {
                DispatchQueue.main.async {
                    completion(.failure(BookmarkManagerError.documentNotInitialized))
                }
                return
            }

            let nativeBookmarks = document.bookmarks
            let bookmarks = nativeBookmarks.map { self.convertToFlutterBookmark($0) }

            DispatchQueue.main.async {
                completion(.success(bookmarks))
            }
        }
    }

    func addBookmark(bookmark: Bookmark, completion: @escaping (Result<Bookmark, Error>) -> Void) {
        queue.async {
            guard let document = self.document else {
                DispatchQueue.main.async {
                    completion(.failure(BookmarkManagerError.documentNotInitialized))
                }
                return
            }

            do {
                let nativeBookmark = try self.convertToNativeBookmark(bookmark, document: document)
                document.bookmarkManager?.addBookmark(nativeBookmark)

                let resultBookmark = self.convertToFlutterBookmark(nativeBookmark)

                DispatchQueue.main.async {
                    completion(.success(resultBookmark))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func removeBookmark(bookmark: Bookmark, completion: @escaping (Result<Bool, Error>) -> Void) {
        queue.async {
            guard let document = self.document else {
                DispatchQueue.main.async {
                    completion(.failure(BookmarkManagerError.documentNotInitialized))
                }
                return
            }

            // Find the bookmark to remove
            let pageIndex = self.parsePageIndexFromAction(bookmark.actionJson)
            let bookmarkToRemove = document.bookmarks.first { nativeBookmark in
                if let action = nativeBookmark.action as? GoToAction {
                    return Int(action.pageIndex) == pageIndex
                }
                // Fallback to name matching
                return bookmark.name != nil && nativeBookmark.name == bookmark.name
            }

            if let bookmarkToRemove = bookmarkToRemove {
                document.bookmarkManager?.removeBookmark(bookmarkToRemove)
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.success(false))
                }
            }
        }
    }

    func updateBookmark(bookmark: Bookmark, completion: @escaping (Result<Bool, Error>) -> Void) {
        // PSPDFKit iOS doesn't have a direct update method, so we remove and re-add
        removeBookmark(bookmark: bookmark) { [weak self] removeResult in
            guard let self = self else {
                completion(.failure(BookmarkManagerError.documentNotInitialized))
                return
            }

            switch removeResult {
            case .success:
                self.addBookmark(bookmark: bookmark) { addResult in
                    switch addResult {
                    case .success:
                        completion(.success(true))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure:
                // If remove failed (bookmark didn't exist), just add it
                self.addBookmark(bookmark: bookmark) { addResult in
                    switch addResult {
                    case .success:
                        completion(.success(true))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    func getBookmarksForPage(pageIndex: Int64, completion: @escaping (Result<[Bookmark], Error>) -> Void) {
        queue.async {
            guard let document = self.document else {
                DispatchQueue.main.async {
                    completion(.failure(BookmarkManagerError.documentNotInitialized))
                }
                return
            }

            let filteredBookmarks = document.bookmarks.filter { nativeBookmark in
                if let action = nativeBookmark.action as? GoToAction {
                    return Int64(action.pageIndex) == pageIndex
                }
                return false
            }.map { self.convertToFlutterBookmark($0) }

            DispatchQueue.main.async {
                completion(.success(filteredBookmarks))
            }
        }
    }

    func hasBookmarkForPage(pageIndex: Int64, completion: @escaping (Result<Bool, Error>) -> Void) {
        getBookmarksForPage(pageIndex: pageIndex) { result in
            switch result {
            case .success(let bookmarks):
                completion(.success(!bookmarks.isEmpty))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Helper Methods

    /// Convert a PSPDFKit Bookmark to Flutter Bookmark.
    private func convertToFlutterBookmark(_ nativeBookmark: PSPDFKit.Bookmark) -> Bookmark {
        var actionJson: String? = nil

        if let action = nativeBookmark.action as? GoToAction {
            let actionDict: [String: Any] = [
                "type": "goTo",
                "pageIndex": action.pageIndex,
                "destinationType": "fitPage"
            ]
            if let jsonData = try? JSONSerialization.data(withJSONObject: actionDict),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                actionJson = jsonString
            }
        }

        return Bookmark(
            pdfBookmarkId: nativeBookmark.identifier,
            name: nativeBookmark.name,
            actionJson: actionJson
        )
    }

    /// Convert Flutter Bookmark to a PSPDFKit Bookmark.
    private func convertToNativeBookmark(_ bookmark: Bookmark, document: Document) throws -> PSPDFKit.Bookmark {
        let pageIndex = parsePageIndexFromAction(bookmark.actionJson) ?? 0
        let action = GoToAction(pageIndex: PageIndex(pageIndex))

        let name = bookmark.name ?? "Page \(pageIndex + 1)"

        // Use existing identifier if provided, otherwise generate a new one
        let identifier = bookmark.pdfBookmarkId ?? UUID().uuidString

        // Generate sortKey based on current bookmark count for ordering
        let sortKey = NSNumber(value: document.bookmarks.count)

        return PSPDFKit.Bookmark(identifier: identifier, action: action, name: name, sortKey: sortKey)
    }

    /// Parse the page index from the action JSON.
    private func parsePageIndexFromAction(_ actionJson: String?) -> Int? {
        guard let actionJson = actionJson,
              let jsonData = actionJson.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let type = json["type"] as? String,
              type == "goTo",
              let pageIndex = json["pageIndex"] as? Int else {
            return nil
        }
        return pageIndex
    }

    // MARK: - Plugin Registration

    @objc public func register(binaryMessenger: FlutterBinaryMessenger) {
        BookmarkManagerApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self,
            messageChannelSuffix: "\(documentId)_bookmark_manager"
        )
    }

    @objc public func unregister(binaryMessenger: FlutterBinaryMessenger) {
        BookmarkManagerApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: nil,
            messageChannelSuffix: "\(documentId)_bookmark_manager"
        )
    }

    // MARK: - Factory Methods

    @objc public static func create(documentId: String, binaryMessenger: FlutterBinaryMessenger) -> BookmarkManagerImpl {
        let manager = BookmarkManagerImpl(documentId: documentId, binaryMessenger: binaryMessenger)
        manager.register(binaryMessenger: binaryMessenger)
        return manager
    }

    @objc public static func createAndInitialize(document: Document, binaryMessenger: FlutterBinaryMessenger) -> BookmarkManagerImpl {
        let documentId = document.uid ?? UUID().uuidString

        // Create and register bookmark manager
        let manager = BookmarkManagerImpl(documentId: documentId, binaryMessenger: binaryMessenger)
        manager.register(binaryMessenger: binaryMessenger)

        // Initialize with document reference
        do {
            try manager.initialize(documentId: documentId)
        } catch {
            print("BookmarkManager: Failed to initialize with document \(documentId): \(error)")
        }

        return manager
    }
}

// MARK: - Error Definitions
enum BookmarkManagerError: LocalizedError {
    case documentNotFound(String)
    case documentNotInitialized
    case invalidJSON(String)

    var errorDescription: String? {
        switch self {
        case .documentNotFound(let id):
            return "Document not found: \(id)"
        case .documentNotInitialized:
            return "Document not initialized"
        case .invalidJSON(let message):
            return "Invalid JSON: \(message)"
        }
    }
}
