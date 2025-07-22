//
//  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation
import PSPDFKit

@objc(PspdfkitPlatformViewImpl)
public class PspdfkitPlatformViewImpl: NSObject, NutrientViewControllerApi, PDFViewControllerDelegate, UIGestureRecognizerDelegate {

    private var pdfViewController: PDFViewController? = nil;
    private var pspdfkitWidgetCallbacks: NutrientViewCallbacks? = nil;
    private var customToolbarCallbacks: CustomToolbarCallbacks? = nil;
    private var viewId: String? = nil;
    private var eventsHelper: FlutterEventsHelper? = nil;
    private var customToolbarItems: [[String: Any]] = [];
    private var lastReportedPageIndex: Int? = nil;
    
    @objc public func setViewController(controller: PDFViewController){
        self.pdfViewController = controller
        self.pdfViewController?.delegate = self
        
        // Set the host view for the annotation toolbar controller
        controller.annotationToolbarController?.updateHostView(nil, container: nil, viewController: controller)
        CustomToolbarHelper.setupCustomToolbarItems(for: pdfViewController!, customToolbarItems:customToolbarItems, callbacks: customToolbarCallbacks)
    }
    
    public func pdfViewController(_ pdfController: PDFViewController, didChange document: Document?) {
        if document != nil {
            // Reset last reported page index when document changes
            lastReportedPageIndex = nil
            pspdfkitWidgetCallbacks?.onDocumentLoaded(documentId: document!.uid){ _ in }
        } else {
            lastReportedPageIndex = nil
            pspdfkitWidgetCallbacks?.onDocumentError(documentId: "", error: "Loading Document failed") {_ in }
        }
    }
    
    public func pdfViewController(_ pdfController: PDFViewController, didSelect annotations: [Annotation], on pageView: PDFPageView) {
        // Call the event helper to notify the listeners.
        eventsHelper?.annotationSelected(annotations: annotations)
    }
    
    public func pdfViewController(_ pdfController: PDFViewController, didDeselect annotations: [Annotation], on pageView: PDFPageView) {
        // Call the event helper to notify the listeners.
        eventsHelper?.annotationDeselected(annotations: annotations)
    }
    
    public func pdfViewController(_ pdfController: PDFViewController, didSelectText text: String, with glyphs: [Glyph], at rect: CGRect, on pageView: PDFPageView) {
        // Call the event helper to notify the listeners.
        eventsHelper?.textSelected(text: text, glyphs: glyphs, rect: rect)
    }
    
    public func pdfViewController(_ pdfController: PDFViewController, didSave document: Document, error: (any Error)?) {
        if let error = error {
            pspdfkitWidgetCallbacks?.onDocumentError(documentId: document.uid, error: error.localizedDescription){_ in }
        } else {
            pspdfkitWidgetCallbacks?.onDocumentSaved(documentId: document.uid, path: document.fileURL?.absoluteString){_ in }
        }
    }
    
    public func pdfViewController(_ pdfController: PDFViewController, didConfigurePageView pageView: PDFPageView, forPageAt pageIndex: Int) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePageTap(_:)))
        tapGesture.delegate = self
        pageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handlePageTap(_ gesture: UITapGestureRecognizer) {
        if let pageView = gesture.view as? PDFPageView {
            let location = gesture.location(in: pageView)
            let point: PointF = PointF(x: Double(Float(location.x)), y: Double(Float(location.y)))
            let pageIndex = Int64(pageView.pageIndex)
            
            // Check if there's an annotation at the tap location
            if let document = pdfViewController?.document {
                // Get annotations for the current page
                let pageAnnotations = document.annotationsForPage(at: PageIndex(pageView.pageIndex), type: .all)
                
                // Find annotation at tap location
                var tappedAnnotation: Annotation? = nil
                for annotation in pageAnnotations {
                    if annotation.boundingBox.contains(location) {
                        tappedAnnotation = annotation
                        break
                    }
                }
                
                // If we found an annotation at the tap location
                if let annotation = tappedAnnotation {
                    // Convert annotation to JSON for the callback using the project's helper
                    if let annotationsJSON = PspdfkitFlutterConverter.instantJSON(from: [annotation]) as? [[String: Any]],
                       let jsonData = try? JSONSerialization.data(withJSONObject: annotationsJSON.first ?? [:], options: []),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        pspdfkitWidgetCallbacks?.onPageClick(documentId: document.uid, pageIndex: pageIndex, point: point, annotation: jsonString){_ in }
                    } else {
                        pspdfkitWidgetCallbacks?.onPageClick(documentId: document.uid, pageIndex: pageIndex, point: point, annotation: nil){_ in }
                    }
                } else {
                    // No annotation at tap location
                    pspdfkitWidgetCallbacks?.onPageClick(documentId: document.uid, pageIndex: pageIndex, point: point, annotation: nil){_ in }
                }
            }
        }
    }
    
    // UIGestureRecognizerDelegate method to determine when to handle taps
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow simultaneous recognition with other gesture recognizers
        // This ensures our tap recognizer doesn't block PSPDFKit's built-in gestures
        return true
    }

    func setFormFieldValue(value: String, fullyQualifiedName: String, completion: @escaping (Result<Bool?, any Error>) -> Void) {
        do {
            guard let document = pdfViewController?.document, document.isValid else {
                completion(.failure(NutrientApiError(code: "", message: "PDF document not found or is invalid.", details: nil)))
                return
            }
            let success = try PspdfkitFlutterHelper.setFormFieldValue(value, forFieldWithFullyQualifiedName: fullyQualifiedName, for: document)
            completion(.success(success))
        } catch {
            completion(.failure(error))
        }
    }
    
    func getFormFieldValue(fullyQualifiedName: String, completion: @escaping (Result<String?, any Error>) -> Void) {
        do {
            guard let document = pdfViewController?.document, document.isValid else {
               completion(.failure(NutrientApiError(code: "", message: "PDF document not found or is invalid.", details: nil)))
                return
            }
            let value = try PspdfkitFlutterHelper.getFormFieldValue(forFieldWithFullyQualifiedName: fullyQualifiedName, for: document)
            completion(.success(value as? String))
        } catch {
            completion(.failure(error))
        }
    }
    
    func applyInstantJson(annotationsJson: String, completion: @escaping (Result<Bool?, any Error>) -> Void) {
        do {
            guard let document = pdfViewController?.document, document.isValid else {
               completion(.failure(NutrientApiError(code: "", message: "PDF document not found or is invalid.", details: nil)))
                return
            }
            let success = try PspdfkitFlutterHelper.applyInstantJson(annotationsJson: annotationsJson, document: document)
            pdfViewController!.reloadData()
            completion(.success(success))
        } catch {
            completion(.failure(error))
        }
    }
    
    func exportInstantJson(completion: @escaping (Result<String?, any Error>) -> Void) {
        do {
            guard let document = pdfViewController?.document, document.isValid else {
               completion(.failure(NutrientApiError(code: "", message: "PDF document not found or is invalid.", details: nil)))
                return
            }
            let json = try PspdfkitFlutterHelper.exportInstantJson(document: document)
            completion(.success(json))
        } catch {
            completion(.failure(error))
        }
    }
    
    func addAnnotation(annotation jsonAnnotation: String, completion: @escaping (Result<Bool?, any Error>) -> Void) {
        do {
            guard let document = pdfViewController?.document, document.isValid else {
               completion(.failure(NutrientApiError(code: "", message: "PDF document not found or is invalid.", details: nil)))
                return
            }
            let success = try PspdfkitFlutterHelper.addAnnotation(jsonAnnotation, for: document)
            completion(.success(success))
        } catch {
            completion(.failure(error))
        }
    }
    
    func removeAnnotation(annotation jsonAnnotation: String, completion: @escaping (Result<Bool?, any Error>) -> Void) {
        do {
            guard let document = pdfViewController?.document, document.isValid else {
               completion(.failure(NutrientApiError(code: "", message: "PDF document not found or is invalid.", details: nil)))
                return
            }
            let success = try PspdfkitFlutterHelper.removeAnnotation(jsonAnnotation, for: document)
            completion(.success(success))
        } catch {
            completion(.failure(error))
        }
    }
    
    func getAnnotations(pageIndex: Int64, type: String, completion: @escaping (Result<Any, any Error>) -> Void) {
        do {
            guard let document = pdfViewController?.document, document.isValid else {
               completion(.failure(NutrientApiError(code: "", message: "PDF document not found or is invalid.", details: nil)))
                return
            }
            let annotations = try PspdfkitFlutterHelper.getAnnotations(forPageIndex: PageIndex(pageIndex), andType: type, for: document)
            completion(.success(annotations))
        } catch {
            completion(.failure(error))
        }
    }
    
    func getAllUnsavedAnnotations(completion: @escaping (Result<Any, any Error>) -> Void) {
        do {
            guard let document = pdfViewController?.document, document.isValid else {
               completion(.failure(NutrientApiError(code: "", message: "PDF document not found or is invalid.", details: nil)))
                return
            }
            let annotations = try PspdfkitFlutterHelper.getAllUnsavedAnnotations(for: document)
            completion(.success(annotations))
        } catch {
            completion(.failure(error))
        }
    }
    
    func processAnnotations(type: AnnotationType, processingMode: AnnotationProcessingMode, destinationPath: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        do {
            let success = try PspdfkitFlutterHelper.processAnnotations(ofType: "\(type)", withProcessingMode: "\(processingMode)", andDestinationPath: destinationPath, for: pdfViewController!)
            completion(.success(success))
        } catch {
            completion(.failure(error))
        }
    }
    
    func importXfdf(xfdfString: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        do {
            guard let document = pdfViewController?.document, document.isValid else {
               completion(.failure(NutrientApiError(code: "", message: "PDF document not found or is invalid.", details: nil)))
                return
            }
            let success = try PspdfkitFlutterHelper.importXFDF(fromString: xfdfString, for: document)
            completion(.success(success))
        } catch {
            completion(.failure(error))
        }
    }
    
    func exportXfdf(xfdfPath: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        do {
            guard let document = pdfViewController?.document, document.isValid else {
               completion(.failure(NutrientApiError(code: "", message: "PDF document not found or is invalid.", details: nil)))
                return
            }
            let success = try PspdfkitFlutterHelper.exportXFDF(toPath: xfdfPath, for: document)
            completion(.success(success))
        } catch {
            completion(.failure(error))
        }
    }
    
    func save(completion: @escaping (Result<Bool, any Error>) -> Void) {
        guard let document = pdfViewController?.document, document.isValid else {
            completion(.failure(NutrientApiError(code: "", message: "Invalid PDF document.", details:   nil )))
            return
        }
        document.save() { Result in
            if case .success = Result {
                completion(.success(true))
            } else {
                let error = NutrientApiError(code: "", message: "Failed to save PDF document.", details:   nil )
                completion(.failure(error))
            }
        }
    }
    
    func setAnnotationConfigurations(configurations: [String : [String : Any]], completion: @escaping (Result<Bool?, any Error>) -> Void) {
        AnnotationsPresetConfigurations.setConfigurations(annotationPreset: configurations)
    }
    
    func getVisibleRect(pageIndex: Int64, completion: @escaping (Result<PdfRect, any Error>) -> Void) {
        guard let pdfViewController = pdfViewController else {
            completion(.failure(NSError(domain: "PspdfkitPlatformViewImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "PDFViewController is not set."])))
            return
        }
        let visibleRect = pdfViewController.viewState?.viewPort
        
        if visibleRect == nil {
            completion(.failure(NSError(domain: "PspdfkitPlatformViewImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "Visible rect is not set."])))
            return
        }
        
        let result: PdfRect = PdfRect(x: visibleRect!.origin.x, y: visibleRect!.origin.y, width: visibleRect!.size.width, height: visibleRect!.size.height)
        completion(.success(result))
    }
    
    func zoomToRect(pageIndex: Int64, rect: PdfRect, animated: Bool?, duration: Double?, completion: @escaping (Result<Bool, any Error>) -> Void) {
        guard let pdfViewController = pdfViewController else {
            completion(.failure(NSError(domain: "PspdfkitPlatformViewImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "PDFViewController is not set."])))
            return
        }
        
        let rectToZoom = CGRect(x: rect.x, y: rect.y, width: rect.width, height: rect.height)
        pdfViewController.documentViewController?.zoom(toPDFRect: rectToZoom, forPageAt: Int(pageIndex), animated: animated ?? true)
        completion(.success(true))
    }
    
    func getZoomScale(pageIndex: Int64, completion: @escaping (Result<Double, any Error>) -> Void) {
        // Not implemented for iOS.
        let errormessage: String = "Not implemented for iOS."
        completion(.failure(NutrientApiError(code: "", message: errormessage, details: nil)))
    }
    
    @objc public func onDocumentLoaded(documentId: String){
        pspdfkitWidgetCallbacks?.onDocumentLoaded(documentId: documentId){_ in }
    }
    
    func addEventListener(event: NutrientEvent) throws {
        eventsHelper?.setEventListener(event: event)
    }
    
    func removeEventListener(event: NutrientEvent) throws {
        eventsHelper?.removeEventListener(event: event)
    }
       
    func enterAnnotationCreationMode(annotationTool: AnnotationTool?, completion: @escaping (Result<Bool?, Error>) -> Void) {
        guard let pdfViewController = pdfViewController else {
            completion(.failure(NutrientApiError(code: "error", message: "PDF view controller is null", details: nil)))
            return
        }
        
        do {
            if let annotationTool = annotationTool {
                // Get the Flutter tool name
                
                // Use AnnotationHelper to map the Flutter tool to iOS tool
                if let toolWithVariant = AnnotationHelper.getIOSAnnotationToolWithVariantFromFlutterName(annotationTool) {
                    // Set the annotation tool
                    if pdfViewController.annotationToolbarController?.isToolbarVisible == false {
                        pdfViewController.annotationToolbarController?.showToolbar(animated: true)
                    }
                    
                    // Handle special cases for tools that need to show pickers or dialogs
                    if toolWithVariant.annotationTool == .stamp {
                        // Show the stamp picker
                        // pdfViewController.annotationStateManager.setState(toolWithVariant.annotationTool, variant: toolWithVariant.variant)
                        pdfViewController.annotationStateManager.toggleStampController(nil)
                        // The stamp picker will be shown automatically when the tool is selected
                        completion(.success(true))
                    } else if toolWithVariant.annotationTool == .image {
                        // For image tool, we need to use the annotation state manager to trigger the image picker
                        // pdfViewController.annotationStateManager.setState(toolWithVariant.annotationTool, variant: toolWithVariant.variant)
                        pdfViewController.annotationStateManager.toggleImagePickerController(nil)
                        // The image picker will be shown automatically when the tool is selected
                        completion(.success(true))
                    } else if toolWithVariant.annotationTool == .signature {
                        // For signature tool, we need to use the annotation state manager to trigger the signature controller
                        // pdfViewController.annotationStateManager.setState(toolWithVariant.annotationTool, variant: toolWithVariant.variant)
                        pdfViewController.annotationStateManager.toggleSignatureController(nil)
                        // The signature dialog will be shown automatically when the tool is selected
                        completion(.success(true))
                    } else {
                        // For all other annotation tools, just toggle the state
                        pdfViewController.annotationStateManager.toggleState(toolWithVariant.annotationTool, variant: toolWithVariant.variant)
                        completion(.success(true))
                    }
                    
                    pdfViewController.annotationStateManager.toggleState(toolWithVariant.annotationTool, variant: toolWithVariant.variant)
                    // Ensure the annotation toolbar is visible
                    completion(.success(true))
                } else {
                    // Default to ink pen if the tool is not supported
                    let defaultTool = AnnotationToolWithVariant(annotationTool: .ink, variant: nil)
                    if pdfViewController.annotationToolbarController?.isToolbarVisible == false {
                        pdfViewController.annotationToolbarController?.showToolbar(animated: true)
                    }
                    pdfViewController.annotationStateManager.toggleState(defaultTool.annotationTool, variant: defaultTool.variant)
                    // Ensure the annotation toolbar is visible
                    completion(.success(true))
                }
            } else {
                // Enter annotation creation mode with default tool (ink pen)
                let defaultTool = AnnotationToolWithVariant(annotationTool: .ink, variant: nil)
                if pdfViewController.annotationToolbarController?.isToolbarVisible == false {
                    pdfViewController.annotationToolbarController?.showToolbar(animated: true)
                }
                
                pdfViewController.annotationStateManager.toggleState(defaultTool.annotationTool, variant: defaultTool.variant)
                completion(.success(true))
            }
        } catch {
            completion(.failure(NutrientApiError(code: "error", message: "Error entering annotation creation mode: \(error.localizedDescription)", details: nil)))
        }
    }
    
    func exitAnnotationCreationMode(completion: @escaping (Result<Bool?, Error>) -> Void) {
        guard let pdfViewController = pdfViewController else {
            completion(.failure(NutrientApiError(code: "error", message: "PDF view controller is null", details: nil)))
            return
        }
        
        do {
            // Exit annotation creation mode
            if pdfViewController.annotationToolbarController?.isToolbarVisible == true {
                pdfViewController.annotationToolbarController?.hideToolbar(animated: true)
            }
            pdfViewController.annotationStateManager.setState(nil, variant: nil)
            completion(.success(true))
        } catch {
            completion(.failure(NutrientApiError(code: "error", message: "Error exiting annotation creation mode: \(error.localizedDescription)", details: nil)))
        }
    }
    
    public func pdfViewController(_ pdfController: PDFViewController, shouldShow controller: UIViewController, options: [String: Any]? = nil, animated: Bool) -> Bool {
        let stampController = PSPDFChildViewControllerForClass(controller, StampViewController.self) as? StampViewController
        // Check if custom default stamps are configured and disable date stamps only if they are
        if AnnotationsPresetConfigurations.hasCustomStampsConfigured() {
            stampController?.dateStampsEnabled = false
        }
        return true
    }

    @objc func spreadIndexDidChange(_ notification: Notification) {
          if let newSpreadIndex = notification.userInfo?["PSPDFDocumentViewControllerSpreadIndexKey"] as? Int,
            let newPageIndex = self.pdfViewController?.documentViewController?.layout.pageRangeForSpread(at: newSpreadIndex).location {
              
              // Only report page change if it's actually different from the last reported page
              if lastReportedPageIndex != newPageIndex {
                  lastReportedPageIndex = newPageIndex
                  let pageIndexInt64 = Int64(newPageIndex)
                  pspdfkitWidgetCallbacks?.onPageChanged(documentId:  self.pdfViewController?.document?.uid ?? "" , pageIndex:pageIndexInt64, completion: { _ in })
              }
          }
    }
    
    @objc public func register( binaryMessenger: FlutterBinaryMessenger, viewId: String, customToolbarItems: [[String: Any]]){
        self.viewId = viewId
        pspdfkitWidgetCallbacks = NutrientViewCallbacks(binaryMessenger: binaryMessenger, messageChannelSuffix: "widget.callbacks.\(viewId)")
        NutrientViewControllerApiSetup.setUp(binaryMessenger: binaryMessenger, api: self, messageChannelSuffix:viewId)
        let nutrientEventCallback: NutrientEventsCallbacks = NutrientEventsCallbacks(binaryMessenger: binaryMessenger, messageChannelSuffix: "events.callbacks.\(viewId)")
        eventsHelper = FlutterEventsHelper(nutrientCallback: nutrientEventCallback)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(spreadIndexDidChange(_:)),
                                               name: .PSPDFDocumentViewControllerSpreadIndexDidChange,
                                               object: nil)
        
        customToolbarCallbacks = CustomToolbarCallbacks(binaryMessenger: binaryMessenger, messageChannelSuffix: "customToolbar.callbacks.\(viewId)")
        self.customToolbarItems = customToolbarItems
    }
    
    @objc public func unRegister(binaryMessenger: FlutterBinaryMessenger){
        NotificationCenter.default.removeObserver(self)
        pspdfkitWidgetCallbacks = nil
        customToolbarCallbacks = nil
        lastReportedPageIndex = nil
        NutrientViewControllerApiSetup.setUp(binaryMessenger: binaryMessenger, api: nil, messageChannelSuffix: viewId ?? "")
        if eventsHelper != nil {
            eventsHelper = nil
        }
    }
}
