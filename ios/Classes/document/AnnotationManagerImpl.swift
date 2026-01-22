//
//  Copyright © 2025-2026 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation
import PSPDFKit
import Flutter

@objc(AnnotationManagerImpl)
public class AnnotationManagerImpl: NSObject, AnnotationManagerApi {

    // MARK: - Properties
    private var document: Document?
    private let documentId: String
    private let binaryMessenger: FlutterBinaryMessenger
    private let queue = DispatchQueue(label: "com.pspdfkit.annotation-manager", qos: .userInitiated)

    // MARK: - Document Registry
    private static var documentRegistry: [String: WeakDocumentReference] = [:]
    private static let registryQueue = DispatchQueue(label: "com.pspdfkit.document-registry", attributes: .concurrent)

    private class WeakDocumentReference {
        weak var document: Document?

        init(_ document: Document) {
            self.document = document
        }
    }

    // MARK: - Initialization
    init(documentId: String, binaryMessenger: FlutterBinaryMessenger) {
        self.documentId = documentId
        self.binaryMessenger = binaryMessenger
        super.init()
    }

    // MARK: - Document Registry Management
    static func registerDocument(_ document: Document, withId documentId: String) {
        registryQueue.async(flags: .barrier) {
            documentRegistry[documentId] = WeakDocumentReference(document)
        }
    }

    @objc static func unregisterDocument(withId documentId: String) {
        registryQueue.async(flags: .barrier) {
            documentRegistry.removeValue(forKey: documentId)
        }
    }

    static func getDocument(withId documentId: String) -> Document? {
        var result: Document?
        registryQueue.sync {
            result = documentRegistry[documentId]?.document
        }
        return result
    }

    // MARK: - AnnotationManagerApi Implementation

    func initialize(documentId: String) throws {
        guard let doc = Self.getDocument(withId: documentId) else {
            throw AnnotationManagerError.documentNotFound(documentId)
        }
        self.document = doc
    }

    func getAnnotationProperties(pageIndex: Int64, annotationId: String, completion: @escaping (Result<AnnotationProperties?, Error>) -> Void) {
        queue.async {
            do {
                guard let document = self.document else {
                    completion(.failure(AnnotationManagerError.documentNotInitialized))
                    return
                }

                let pageIdx = PageIndex(pageIndex)
                guard pageIdx < document.pageCount else {
                    completion(.failure(AnnotationManagerError.invalidPageIndex(pageIndex)))
                    return
                }

                let annotations = document.annotationsForPage(at: pageIdx, type: .all)

                guard let annotation = annotations.first(where: { $0.uuid == annotationId || $0.name == annotationId }) else {
                    completion(.success(nil))
                    return
                }

                let properties = self.buildAnnotationProperties(from: annotation, pageIndex: pageIndex)
                completion(.success(properties))

            } catch {
                completion(.failure(error))
            }
        }
    }

    func saveAnnotationProperties(modifiedProperties: AnnotationProperties, completion: @escaping (Result<Bool, Error>) -> Void) {
        queue.async {
            do {
                guard let document = self.document else {
                    completion(.failure(AnnotationManagerError.documentNotInitialized))
                    return
                }

                let pageIdx = PageIndex(modifiedProperties.pageIndex)
                let annotations = document.annotationsForPage(at: pageIdx, type: .all)

                guard let annotation = annotations.first(where: {
                    $0.uuid == modifiedProperties.annotationId || $0.name == modifiedProperties.annotationId
                }) else {
                    completion(.failure(AnnotationManagerError.annotationNotFound(modifiedProperties.annotationId)))
                    return
                }

                // Preserve existing attachments and custom data
                let existingCustomData = annotation.customData
                let existingAttachments = self.getAnnotationAttachments(annotation)

                // Update only the properties that are not nil
                self.updateAnnotation(annotation, with: modifiedProperties)

                // Restore preserved data if it wasn't explicitly updated
                if modifiedProperties.customDataJson == nil {
                    annotation.customData = existingCustomData
                }

                // Restore attachments
                self.restoreAnnotationAttachments(annotation, attachments: existingAttachments)

                // Mark as modified and save
                document.add(annotations: [annotation], options: nil)

                DispatchQueue.main.async {
                    completion(.success(true))
                }

            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func getAnnotationsJson(pageIndex: Int64, annotationType: String, completion: @escaping (Result<String, Error>) -> Void) {
        queue.async {
            do {
                guard let document = self.document else {
                    completion(.failure(AnnotationManagerError.documentNotInitialized))
                    return
                }

                let pageIdx = PageIndex(pageIndex)
                guard pageIdx < document.pageCount else {
                    completion(.failure(AnnotationManagerError.invalidPageIndex(pageIndex)))
                    return
                }

                var annotations = document.annotationsForPage(at: pageIdx, type: .all)

                // Filter by type if not "all"
                if annotationType != "all" {
                    annotations = annotations.filter { annotation in
                        self.getAnnotationType(for: annotation) == annotationType
                    }
                }

                // Convert to JSON objects using PSPDFKit's generateInstantJSON
                // Use compactMap to skip annotations that fail to serialize, rather than
                // failing the entire operation (some annotations may not serialize well)
                var results: [Any] = []
                for annotation in annotations {
                    do {
                        let jsonData = try annotation.generateInstantJSON()
                        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                            results.append(jsonObject)
                        }
                    } catch {
                        // Skip annotations that can't be serialized
                    }
                }

                // Convert to JSON string
                let jsonData = try JSONSerialization.data(withJSONObject: results, options: [])
                let jsonString = String(data: jsonData, encoding: .utf8) ?? "[]"

                DispatchQueue.main.async {
                    completion(.success(jsonString))
                }

            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func addAnnotation(jsonAnnotation: String, jsonAttachment: String?, completion: @escaping (Result<String, Error>) -> Void) {
        queue.async {
            do {
                guard let document = self.document else {
                    completion(.failure(AnnotationManagerError.documentNotInitialized))
                    return
                }

                guard let jsonData = jsonAnnotation.data(using: .utf8),
                      let annotationDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                    completion(.failure(AnnotationManagerError.invalidJSON("Failed to parse annotation JSON")))
                    return
                }

                let annotation = try self.createAnnotationFromJSON(annotationDict, document: document)

                // Handle attachment if provided
                if let attachmentJSON = jsonAttachment {
                    try self.handleAnnotationAttachment(annotation, attachmentJSON: attachmentJSON)
                }

                // Add annotation to document
                document.add(annotations: [annotation], options: nil)

                DispatchQueue.main.async {
                    completion(.success(annotation.uuid))
                }

            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func removeAnnotation(pageIndex: Int64, annotationId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        queue.async {
            do {
                guard let document = self.document else {
                    completion(.failure(AnnotationManagerError.documentNotInitialized))
                    return
                }

                let pageIdx = PageIndex(pageIndex)
                let annotations = document.annotationsForPage(at: pageIdx, type: .all)

                guard let annotation = annotations.first(where: {
                    $0.uuid == annotationId || $0.name == annotationId
                }) else {
                    DispatchQueue.main.async {
                        completion(.success(false))
                    }
                    return
                }

                document.remove(annotations: [annotation], options: nil)

                DispatchQueue.main.async {
                    completion(.success(true))
                }

            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func searchAnnotationsJson(query: String, pageIndex: Int64?, completion: @escaping (Result<String, Error>) -> Void) {
        queue.async {
            do {
                guard let document = self.document else {
                    completion(.failure(AnnotationManagerError.documentNotInitialized))
                    return
                }

                var results: [[String: Any?]] = []
                let pages: [PageIndex]

                if let pageIdx = pageIndex {
                    pages = [PageIndex(pageIdx)]
                } else {
                    pages = Array(0..<document.pageCount).map { PageIndex($0) }
                }

                for pageIdx in pages {
                    let annotations = document.annotationsForPage(at: pageIdx, type: .all)

                    let matching = annotations.filter { annotation in
                        return annotation.contents?.localizedCaseInsensitiveContains(query) == true ||
                               annotation.subject?.localizedCaseInsensitiveContains(query) == true ||
                               (annotation as? NoteAnnotation)?.contents?.localizedCaseInsensitiveContains(query) == true
                    }

                    results.append(contentsOf: matching.map { self.annotationToMap($0) })
                }

                // Convert to JSON string
                let jsonData = try JSONSerialization.data(withJSONObject: results, options: [])
                let jsonString = String(data: jsonData, encoding: .utf8) ?? "[]"

                DispatchQueue.main.async {
                    completion(.success(jsonString))
                }

            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func exportXFDF(pageIndex: Int64?, completion: @escaping (Result<String, Error>) -> Void) {
        queue.async {
            do {
                guard let document = self.document else {
                    completion(.failure(AnnotationManagerError.documentNotInitialized))
                    return
                }

                var annotations: [Annotation] = []

                if let pageIdx = pageIndex {
                    annotations = document.annotationsForPage(at: PageIndex(pageIdx), type: .all)
                } else {
                    // Export all annotations from all pages
                    for page in 0..<document.pageCount {
                        annotations.append(contentsOf: document.annotationsForPage(at: PageIndex(page), type: .all))
                    }
                }

                // Use XFDFWriter to generate XFDF
                let writer = XFDFWriter()
                let dataSink = DataContainerSink(data: Data())
                try writer.write(annotations, to: dataSink, documentProvider: document.documentProviders.first!)
                let xfdfData = dataSink.data
                let xfdfString = String(data: xfdfData, encoding: .utf8) ?? ""

                DispatchQueue.main.async {
                    completion(.success(xfdfString))
                }

            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func importXFDF(xfdfString: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        queue.async {
            do {
                guard let document = self.document else {
                    completion(.failure(AnnotationManagerError.documentNotInitialized))
                    return
                }

                guard let xfdfData = xfdfString.data(using: .utf8) else {
                    completion(.failure(AnnotationManagerError.invalidXFDF("Failed to convert XFDF string to data")))
                    return
                }

                // Use XFDFParser to parse XFDF
                let dataProvider = DataContainerProvider(data: xfdfData)
                let parser = XFDFParser(dataProvider: dataProvider, documentProvider: document.documentProviders.first!)
                try parser.parse()
                let annotations = parser.annotations
                document.add(annotations: annotations, options: nil)

                DispatchQueue.main.async {
                    completion(.success(true))
                }

            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func getUnsavedAnnotationsJson(completion: @escaping (Result<String, Error>) -> Void) {
        queue.async {
            do {
                guard let document = self.document else {
                    completion(.failure(AnnotationManagerError.documentNotInitialized))
                    return
                }

                // Note: .dirty flag is no longer available in PSPDFKit SDK
                // For now, return empty array. A proper implementation would require
                // tracking changes at the application level or using document change notifications
                let results: [[String: Any?]] = []

                // Convert to JSON string
                let jsonData = try JSONSerialization.data(withJSONObject: results, options: [])
                let jsonString = String(data: jsonData, encoding: .utf8) ?? "[]"

                DispatchQueue.main.async {
                    completion(.success(jsonString))
                }

            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func buildAnnotationProperties(from annotation: Annotation, pageIndex: Int64) -> AnnotationProperties {
        return AnnotationProperties(
            annotationId: annotation.uuid,
            pageIndex: pageIndex,
            strokeColor: annotation.color?.argbValue,
            fillColor: annotation.fillColor?.argbValue,
            opacity: Double(annotation.alpha),
            lineWidth: annotation.lineWidth != 0 ? Double(annotation.lineWidth) : nil,
            flagsJson: getAnnotationFlagsJson(annotation),
            customDataJson: getCustomDataJson(from: annotation),
            contents: annotation.contents,
            subject: annotation.subject,
            creator: annotation.user,
            bboxJson: getBboxJson(from: annotation),
            note: (annotation as? NoteAnnotation)?.contents,
            inkLinesJson: getInkLinesJson(from: annotation),
            fontName: getFontName(from: annotation),
            fontSize: getFontSize(from: annotation),
            iconName: getIconName(from: annotation)
        )
    }

    private func updateAnnotation(_ annotation: Annotation, with properties: AnnotationProperties) {
        if let strokeColor = properties.strokeColor {
            annotation.color = UIColor(argb: strokeColor)
        }

        if let fillColor = properties.fillColor {
            annotation.fillColor = UIColor(argb: fillColor)
        }

        if let opacity = properties.opacity {
            annotation.alpha = CGFloat(opacity)
        }

        if let lineWidth = properties.lineWidth {
            annotation.lineWidth = CGFloat(lineWidth)
        }

        if let contents = properties.contents {
            annotation.contents = contents
        }

        if let subject = properties.subject {
            annotation.subject = subject
        }

        if let creator = properties.creator {
            annotation.user = creator
        }

        if let customDataJson = properties.customDataJson,
           !customDataJson.isEmpty,
           let jsonData = customDataJson.data(using: .utf8),
           let customData = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            annotation.customData = customData
        }

        if let flagsJson = properties.flagsJson,
           let flags = decodeFlagsJson(flagsJson) {
            updateAnnotationFlags(annotation, flags: flags)
        }

        if let note = properties.note, let noteAnnotation = annotation as? NoteAnnotation {
            noteAnnotation.contents = note
        }

        if let bboxJson = properties.bboxJson,
           let bbox = decodeBboxJson(bboxJson), bbox.count >= 4 {
            annotation.boundingBox = CGRect(
                x: CGFloat(bbox[0]),
                y: CGFloat(bbox[1]),
                width: CGFloat(bbox[2]),
                height: CGFloat(bbox[3])
            )
        }

        if let inkLinesJson = properties.inkLinesJson,
           let inkLines = decodeInkLines(from: inkLinesJson),
           let inkAnnotation = annotation as? InkAnnotation {
            setInkLines(inkAnnotation, lines: inkLines)
        }

        if let fontName = properties.fontName, let freeTextAnnotation = annotation as? FreeTextAnnotation {
            freeTextAnnotation.fontName = fontName
        }

        if let fontSize = properties.fontSize, let freeTextAnnotation = annotation as? FreeTextAnnotation {
            freeTextAnnotation.fontSize = CGFloat(fontSize)
        }

        if let iconName = properties.iconName, let noteAnnotation = annotation as? NoteAnnotation {
            noteAnnotation.iconName = iconName
        }
    }

    private func annotationToMap(_ annotation: Annotation) -> [String: Any?] {
        return [
            "id": annotation.uuid,
            "pageIndex": annotation.pageIndex,
            "type": getAnnotationType(for: annotation),
            "bbox": [
                Double(annotation.boundingBox.minX),
                Double(annotation.boundingBox.minY),
                Double(annotation.boundingBox.width),
                Double(annotation.boundingBox.height)
            ],
            "contents": annotation.contents,
            "subject": annotation.subject,
            "creator": annotation.user,
            "note": (annotation as? NoteAnnotation)?.contents,
            "color": annotation.color?.argbValue,
            "fillColor": annotation.fillColor?.argbValue,
            "opacity": Double(annotation.alpha),
            "lineWidth": annotation.lineWidth != 0 ? Double(annotation.lineWidth) : nil,
            "flags": getAnnotationFlags(annotation),
            "customData": annotation.customData,
            "fontName": getFontName(from: annotation),
            "fontSize": getFontSize(from: annotation),
            "iconName": getIconName(from: annotation),
            "inkLines": getInkLines(from: annotation)
        ]
    }

    private func getAnnotationType(for annotation: Annotation) -> String {
        // Return Instant JSON format type strings
        switch annotation {
        case is InkAnnotation:
            return "pspdfkit/ink"
        case is HighlightAnnotation:
            return "pspdfkit/markup/highlight"
        case is UnderlineAnnotation:
            return "pspdfkit/markup/underline"
        case is StrikeOutAnnotation:
            return "pspdfkit/markup/strikeout"
        case is SquigglyAnnotation:
            return "pspdfkit/markup/squiggly"
        case is SquareAnnotation:
            return "pspdfkit/shape/rectangle"
        case is CircleAnnotation:
            return "pspdfkit/shape/ellipse"
        case is LineAnnotation:
            return "pspdfkit/shape/line"
        case is PolygonAnnotation:
            return "pspdfkit/shape/polygon"
        case is PolyLineAnnotation:
            return "pspdfkit/shape/polyline"
        case is FreeTextAnnotation:
            return "pspdfkit/text"
        case is NoteAnnotation:
            return "pspdfkit/note"
        case is StampAnnotation:
            return "pspdfkit/stamp"
        case is LinkAnnotation:
            return "pspdfkit/link"
        case is RedactionAnnotation:
            return "pspdfkit/markup/redaction"
        case is WidgetAnnotation:
            return "pspdfkit/widget"
        case is SoundAnnotation:
            return "pspdfkit/sound"
        case is CaretAnnotation:
            return "pspdfkit/caret"
        case is PopupAnnotation:
            return "pspdfkit/popup"
        case is ScreenAnnotation:
            return "pspdfkit/screen"
        case is RichMediaAnnotation:
            return "pspdfkit/media"
        default:
            // Return undefined for unknown types so they are skipped
            return "pspdfkit/undefined"
        }
    }

    /// Gets annotation flags and returns them as a JSON string array.
    private func getAnnotationFlagsJson(_ annotation: Annotation) -> String {
        var flags: [String] = []

        if annotation.flags.contains(.hidden) {
            flags.append("hidden")
        }
        if annotation.flags.contains(.invisible) {
            flags.append("invisible")
        }
        if annotation.flags.contains(.print) {
            flags.append("print")
        }
        if annotation.flags.contains(.noZoom) {
            flags.append("noZoom")
        }
        if annotation.flags.contains(.noRotate) {
            flags.append("noRotate")
        }
        if annotation.flags.contains(.noView) {
            flags.append("noView")
        }
        if annotation.flags.contains(.readOnly) {
            flags.append("readOnly")
        }
        if annotation.flags.contains(.locked) {
            flags.append("locked")
        }
        if annotation.flags.contains(.toggleNoView) {
            flags.append("toggleNoView")
        }
        if annotation.flags.contains(.lockedContents) {
            flags.append("lockedContents")
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: flags),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "[]"
        }
        return jsonString
    }

    /// Gets annotation flags and returns them as a string array.
    /// Used by annotationToMap() for building JSON dictionaries.
    private func getAnnotationFlags(_ annotation: Annotation) -> [String] {
        var flags: [String] = []

        if annotation.flags.contains(.hidden) {
            flags.append("hidden")
        }
        if annotation.flags.contains(.invisible) {
            flags.append("invisible")
        }
        if annotation.flags.contains(.print) {
            flags.append("print")
        }
        if annotation.flags.contains(.noZoom) {
            flags.append("noZoom")
        }
        if annotation.flags.contains(.noRotate) {
            flags.append("noRotate")
        }
        if annotation.flags.contains(.noView) {
            flags.append("noView")
        }
        if annotation.flags.contains(.readOnly) {
            flags.append("readOnly")
        }
        if annotation.flags.contains(.locked) {
            flags.append("locked")
        }
        if annotation.flags.contains(.toggleNoView) {
            flags.append("toggleNoView")
        }
        if annotation.flags.contains(.lockedContents) {
            flags.append("lockedContents")
        }

        return flags
    }

    /// Decodes flags from JSON string array.
    private func decodeFlagsJson(_ json: String) -> [String]? {
        guard let jsonData = json.data(using: .utf8),
              let flags = try? JSONSerialization.jsonObject(with: jsonData) as? [String] else {
            return nil
        }
        return flags
    }

    /// Gets bounding box and returns it as a JSON string array [x, y, width, height].
    private func getBboxJson(from annotation: Annotation) -> String {
        let bbox = [
            Double(annotation.boundingBox.minX),
            Double(annotation.boundingBox.minY),
            Double(annotation.boundingBox.width),
            Double(annotation.boundingBox.height)
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: bbox),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "[]"
        }
        return jsonString
    }

    /// Decodes bbox from JSON string array.
    private func decodeBboxJson(_ json: String) -> [Double]? {
        guard let jsonData = json.data(using: .utf8),
              let bbox = try? JSONSerialization.jsonObject(with: jsonData) as? [Double] else {
            return nil
        }
        return bbox
    }

    private func updateAnnotationFlags(_ annotation: Annotation, flags: [String]) {
        // Clear existing flags and build new set based on provided flags
        var newFlags: Annotation.Flag = []

        if flags.contains("hidden") {
            newFlags.insert(.hidden)
        }
        if flags.contains("invisible") {
            newFlags.insert(.invisible)
        }
        if flags.contains("print") {
            newFlags.insert(.print)
        }
        if flags.contains("noZoom") {
            newFlags.insert(.noZoom)
        }
        if flags.contains("noRotate") {
            newFlags.insert(.noRotate)
        }
        if flags.contains("noView") {
            newFlags.insert(.noView)
        }
        if flags.contains("readOnly") {
            newFlags.insert(.readOnly)
        }
        if flags.contains("locked") {
            newFlags.insert(.locked)
        }
        if flags.contains("toggleNoView") {
            newFlags.insert(.toggleNoView)
        }
        if flags.contains("lockedContents") {
            newFlags.insert(.lockedContents)
        }

        annotation.flags = newFlags
    }

    /// Gets ink lines from an InkAnnotation and returns them as a JSON string.
    /// Format: [[[x, y, pressure], [x, y, pressure], ...], ...]
    private func getInkLinesJson(from annotation: Annotation) -> String? {
        guard let inkAnnotation = annotation as? InkAnnotation,
              let lines = inkAnnotation.lines else {
            return nil
        }

        let inkLines = lines.map { line in
            line.map { point in
                [Double(point.location.x), Double(point.location.y), Double(point.intensity)]
            }
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: inkLines),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }

        return jsonString
    }

    /// Gets ink lines from an InkAnnotation and returns them as an array.
    /// Used by annotationToMap() for building JSON dictionaries.
    /// Format: [[[x, y, pressure], [x, y, pressure], ...], ...]
    private func getInkLines(from annotation: Annotation) -> [[[Double]]]? {
        guard let inkAnnotation = annotation as? InkAnnotation,
              let lines = inkAnnotation.lines else {
            return nil
        }

        return lines.map { line in
            line.map { point in
                [Double(point.location.x), Double(point.location.y), Double(point.intensity)]
            }
        }
    }

    /// Decodes ink lines from a JSON string.
    private func decodeInkLines(from json: String) -> [[[Double]]]? {
        guard let jsonData = json.data(using: .utf8),
              let inkLines = try? JSONSerialization.jsonObject(with: jsonData) as? [[[Double]]] else {
            return nil
        }
        return inkLines
    }

    /// Gets custom data from an annotation and returns it as a JSON string.
    private func getCustomDataJson(from annotation: Annotation) -> String? {
        guard let customData = annotation.customData else {
            return nil
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: customData),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }

        return jsonString
    }

    private func setInkLines(_ inkAnnotation: InkAnnotation, lines: [[[Double]]]) {
        let inkLines: [[DrawingPoint]] = lines.map { line in
            line.compactMap { point in
                guard point.count >= 2 else { return nil }
                let intensity = point.count >= 3 ? CGFloat(point[2]) : 1.0
                return DrawingPoint(location: CGPoint(x: CGFloat(point[0]), y: CGFloat(point[1])), intensity: intensity)
            }
        }
        inkAnnotation.lines = inkLines
    }

    private func getFontName(from annotation: Annotation) -> String? {
        return (annotation as? FreeTextAnnotation)?.fontName
    }

    private func getFontSize(from annotation: Annotation) -> Double? {
        guard let freeTextAnnotation = annotation as? FreeTextAnnotation else {
            return nil
        }
        return Double(freeTextAnnotation.fontSize)
    }

    private func getIconName(from annotation: Annotation) -> String? {
        return (annotation as? NoteAnnotation)?.iconName
    }

    private func getAnnotationAttachments(_ annotation: Annotation) -> [String: Any]? {
        // Store attachment information that needs to be preserved
        // FileAttachmentAnnotation is no longer available in current PSPDFKit SDK
        // File attachment functionality has been removed
        return nil
    }

    private func restoreAnnotationAttachments(_ annotation: Annotation, attachments: [String: Any]?) {
        guard let attachments = attachments,
              let type = attachments["type"] as? String else {
            return
        }

        // FileAttachmentAnnotation is no longer available in current PSPDFKit SDK
        // File attachment functionality has been removed
        // if type == "file", let fileAnnotation = annotation as? FileAttachmentAnnotation {
        //     // File attachment handling code removed
        // }
    }

    private func createAnnotationFromJSON(_ jsonDict: [String: Any], document: Document) throws -> Annotation {
        guard let type = jsonDict["type"] as? String else {
            throw AnnotationManagerError.invalidJSON("Missing annotation type")
        }

        guard let pageIndex = jsonDict["pageIndex"] as? Int,
              let bbox = jsonDict["bbox"] as? [Double], bbox.count >= 4 else {
            throw AnnotationManagerError.invalidJSON("Missing required annotation properties")
        }

        let boundingBox = CGRect(
            x: CGFloat(bbox[0]),
            y: CGFloat(bbox[1]),
            width: CGFloat(bbox[2]),
            height: CGFloat(bbox[3])
        )

        let annotation: Annotation

        switch type {
        case "ink":
            annotation = try InkAnnotation(dictionary: [:])
            if let inkLines = jsonDict["inkLines"] as? [[[Double]]] {
                setInkLines(annotation as! InkAnnotation, lines: inkLines)
            }
        case "highlight":
            annotation = try HighlightAnnotation(dictionary: [:])
        case "underline":
            annotation = try UnderlineAnnotation(dictionary: [:])
        case "strikeOut":
            annotation = try StrikeOutAnnotation(dictionary: [:])
        case "squiggly":
            annotation = try SquigglyAnnotation(dictionary: [:])
        case "square":
            annotation = try SquareAnnotation(dictionary: [:])
        case "circle":
            annotation = try CircleAnnotation(dictionary: [:])
        case "line":
            annotation = try LineAnnotation(dictionary: [:])
        case "polygon":
            annotation = try PolygonAnnotation(dictionary: [:])
        case "polyline":
            annotation = try PolyLineAnnotation(dictionary: [:])
        case "freeText":
            let freeTextDict = jsonDict["contents"] != nil ? ["contents": jsonDict["contents"] as Any] : [:]
            annotation = try FreeTextAnnotation(dictionary: freeTextDict)
            if let fontName = jsonDict["fontName"] as? String {
                (annotation as! FreeTextAnnotation).fontName = fontName
            }
            if let fontSize = jsonDict["fontSize"] as? Double {
                (annotation as! FreeTextAnnotation).fontSize = CGFloat(fontSize)
            }
        case "note":
            let noteDict = jsonDict["contents"] != nil ? ["contents": jsonDict["contents"] as Any] : [:]
            annotation = try NoteAnnotation(dictionary: noteDict)
            if let note = jsonDict["note"] as? String {
                (annotation as! NoteAnnotation).contents = note
            }
            if let iconName = jsonDict["iconName"] as? String {
                (annotation as! NoteAnnotation).iconName = iconName
            }
        case "stamp":
            annotation = try StampAnnotation(dictionary: [:])
        case "file":
            // FileAttachmentAnnotation is no longer available in current PSPDFKit SDK
            // For now, throw an error for file attachment creation
            throw AnnotationManagerError.unsupportedAnnotationType("FileAttachmentAnnotation is not supported in current SDK version")
        default:
            throw AnnotationManagerError.unsupportedAnnotationType(type)
        }

        // Set common properties
        annotation.boundingBox = boundingBox
        annotation.pageIndex = PageIndex(pageIndex)

        if let contents = jsonDict["contents"] as? String {
            annotation.contents = contents
        }

        if let subject = jsonDict["subject"] as? String {
            annotation.subject = subject
        }

        if let creator = jsonDict["creator"] as? String {
            annotation.user = creator
        }

        if let strokeColor = jsonDict["strokeColor"] as? Int64 {
            annotation.color = UIColor(argb: strokeColor)
        }

        if let fillColor = jsonDict["fillColor"] as? Int64 {
            annotation.fillColor = UIColor(argb: fillColor)
        }

        if let opacity = jsonDict["opacity"] as? Double {
            annotation.alpha = CGFloat(opacity)
        }

        if let lineWidth = jsonDict["lineWidth"] as? Double {
            annotation.lineWidth = CGFloat(lineWidth)
        }

        if let customData = jsonDict["customData"] as? [String: Any] {
            annotation.customData = customData
        }

        if let flags = jsonDict["flags"] as? [String] {
            updateAnnotationFlags(annotation, flags: flags)
        }

        return annotation
    }

    private func handleAnnotationAttachment(_ annotation: Annotation, attachmentJSON: String) throws {
        guard let jsonData = attachmentJSON.data(using: .utf8),
              let attachmentDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw AnnotationManagerError.invalidJSON("Failed to parse attachment JSON")
        }

        // FileAttachmentAnnotation is no longer available in current PSPDFKit SDK
        // File attachment functionality has been removed
        // if let fileAnnotation = annotation as? FileAttachmentAnnotation {
        //     // File attachment handling code removed
        // }
    }

    // MARK: - Plugin Registration

    @objc public func register(binaryMessenger: FlutterBinaryMessenger) {
        AnnotationManagerApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self,
            messageChannelSuffix: "\(documentId)_annotation_manager"
        )
    }

    @objc public func unregister(binaryMessenger: FlutterBinaryMessenger) {
        AnnotationManagerApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: nil,
            messageChannelSuffix: "\(documentId)_annotation_manager"
        )
    }

    // MARK: - Factory Methods

    @objc public static func create(documentId: String, binaryMessenger: FlutterBinaryMessenger) -> AnnotationManagerImpl {
        let manager = AnnotationManagerImpl(documentId: documentId, binaryMessenger: binaryMessenger)
        manager.register(binaryMessenger: binaryMessenger)
        return manager
    }

    @objc public static func createAndInitialize(document: Document, binaryMessenger: FlutterBinaryMessenger) -> AnnotationManagerImpl {
        let documentId = document.uid ?? UUID().uuidString

        // Register document in the registry
        AnnotationManagerImpl.registerDocument(document, withId: documentId)

        // Create and register annotation manager
        let manager = AnnotationManagerImpl(documentId: documentId, binaryMessenger: binaryMessenger)
        manager.register(binaryMessenger: binaryMessenger)

        // Initialize with document reference
        do {
            try manager.initialize(documentId: documentId)
        } catch {
            // Log error but don't fail - the manager can be initialized later
            print("AnnotationManager: Failed to initialize with document \(documentId): \(error)")
        }

        return manager
    }
}

// MARK: - UIColor Extension for ARGB Conversion
extension UIColor {
    convenience init(argb: Int64) {
        let alpha = CGFloat((argb >> 24) & 0xFF) / 255.0
        let red = CGFloat((argb >> 16) & 0xFF) / 255.0
        let green = CGFloat((argb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(argb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    var argbValue: Int64 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let a = Int64(alpha * 255) << 24
        let r = Int64(red * 255) << 16
        let g = Int64(green * 255) << 8
        let b = Int64(blue * 255)

        return a | r | g | b
    }
}

// MARK: - Error Definitions
enum AnnotationManagerError: LocalizedError {
    case documentNotFound(String)
    case documentNotInitialized
    case annotationNotFound(String)
    case invalidPageIndex(Int64)
    case invalidJSON(String)
    case invalidXFDF(String)
    case unsupportedAnnotationType(String)

    var errorDescription: String? {
        switch self {
        case .documentNotFound(let id):
            return "Document not found: \(id)"
        case .documentNotInitialized:
            return "Document not initialized"
        case .annotationNotFound(let id):
            return "Annotation not found: \(id)"
        case .invalidPageIndex(let index):
            return "Invalid page index: \(index)"
        case .invalidJSON(let message):
            return "Invalid JSON: \(message)"
        case .invalidXFDF(let message):
            return "Invalid XFDF: \(message)"
        case .unsupportedAnnotationType(let type):
            return "Unsupported annotation type: \(type)"
        }
    }
}

