//
//  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation

class FlutterEventsHelper: NSObject {

    private var nutrientCallback: NutrientEventsCallbacks? = nil
    private var observers: [NutrientEvent: NSObjectProtocol] = [:]

    // External listeners are listeners sent from other classes. For example the PlatformViewImpl class.
    private var externalListeners: [NutrientEvent] = []
    
    // Track selector-based observers for defensive cleanup
    private var selectorObserverEvents: Set<NutrientEvent> = []
    
    // Flag to track if cleanup has been performed
    private var isCleanedUp = false

    public init(nutrientCallback: NutrientEventsCallbacks?) {
        self.nutrientCallback = nutrientCallback
        super.init()
    }

    func setEventListener(event: NutrientEvent) {
        // Prevent setting listeners if already cleaned up
        guard !isCleanedUp else {
            NSLog("FlutterEventsHelper: Attempted to set event listener after cleanup for event: \(event)")
            return
        }
        
        // Remove existing listener for this event to prevent duplicates
        removeEventListener(event: event)
        
        switch event {
        case .annotationsCreated:
            let observer = NotificationCenter.default.addObserver(
                forName: .PSPDFAnnotationsAdded,
                object: nil,
                queue: nil
            ) { [weak self] notification in
                guard let self = self, !self.isCleanedUp else { return }
                self.annotationsAddedNotification(notification: notification)
            }
            observers[event] = observer
            break
        case .annotationsDeleted:
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(
                    annotationsRemovedNotification(notification:)),
                name: .PSPDFAnnotationsRemoved,
                object: nil)
            selectorObserverEvents.insert(event)
            break
        case .annotationsUpdated:
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(
                    annotationChangedNotification(notification:)),
                name: .PSPDFAnnotationChanged,
                object: nil)
            selectorObserverEvents.insert(event)
            break
        case .annotationsSelected:
            if !externalListeners.contains(event) {
                externalListeners.append(event)
            }
            break
        case .annotationsDeselected:
            if !externalListeners.contains(event) {
                externalListeners.append(event)
            }
            break
        case .textSelectionChanged:
            if !externalListeners.contains(event) {
                externalListeners.append(event)
            }
            break
        case .formFieldValuesUpdated:
            let observer = NotificationCenter.default.addObserver(
                forName: .PSPDFAnnotationChanged,
                object: nil,
                queue: nil
            ) { [weak self] notification in
                guard let self = self, !self.isCleanedUp else { return }
                self.formFieldValueChangedNotification(
                    notification: notification)
            }
            observers[event] = observer
            break
        case .formFieldSelected:
            if !externalListeners.contains(event) {
                externalListeners.append(event)
            }
            break
        case .formFieldDeselected:
            if !externalListeners.contains(event) {
                externalListeners.append(event)
            }
            break
        }
    }

    @objc func annotationsAddedNotification(notification: Notification) {
        guard !isCleanedUp, let nutrientCallback = nutrientCallback else { return }
        
        if let annotations = notification.object as? [Annotation] {
            let annotationJSON = PspdfkitFlutterConverter.instantJSON(
                from: annotations)
            nutrientCallback.onEvent(
                event: NutrientEvent.annotationsCreated,
                data: ["annotations": annotationJSON]
            ) { _ in }
        }
    }

    @objc func annotationsRemovedNotification(notification: Notification) {
        guard !isCleanedUp, let nutrientCallback = nutrientCallback else { return }
        
        if let annotations = notification.object as? [Annotation] {
            let annotationJSON = PspdfkitFlutterConverter.instantJSON(
                from: annotations)
            nutrientCallback.onEvent(
                event: NutrientEvent.annotationsDeleted,
                data: ["annotations": annotationJSON]
            ) { _ in }
        }
    }

    @objc func annotationChangedNotification(notification: Notification) {
        guard !isCleanedUp, let nutrientCallback = nutrientCallback else { return }
        
        if let annotation = notification.object as? Annotation {
            let annotationJSON = PspdfkitFlutterConverter.instantJSON(from: [
                annotation
            ])
            nutrientCallback.onEvent(
                event: NutrientEvent.annotationsUpdated,
                data: ["annotations": annotationJSON]
            ) { _ in }
        }
    }

    @objc func formFieldValueChangedNotification(notification: Notification) {
        guard !isCleanedUp, let nutrientCallback = nutrientCallback else { return }
        
        // Check if the notification object is a FormElement.
        guard let annotation = notification.object as? [FormElement] else {
            return
        }
        let annotationJSON = PspdfkitFlutterConverter.instantJSON(
            from: annotation)
        nutrientCallback.onEvent(
            event: NutrientEvent.formFieldValuesUpdated,
            data: ["formField": annotationJSON]
        ) { _ in }
    }

    @objc func textSelected(text: String, glyphs: [Glyph], rect: CGRect) {
        guard !isCleanedUp, let nutrientCallback = nutrientCallback else { return }
        
        if externalListeners.contains(.textSelectionChanged) {
            nutrientCallback.onEvent(
                event: NutrientEvent.textSelectionChanged, data: ["text": text]
            ) { _ in }
        }
    }

    func annotationSelected(annotations: [Annotation]) {
        guard !isCleanedUp, let nutrientCallback = nutrientCallback else { return }
        
        if isFormElements(annotations: annotations) {
            if externalListeners.contains(.formFieldSelected) {
                let annotationsJSON = PspdfkitFlutterConverter.instantJSON(
                    from: annotations)
                nutrientCallback.onEvent(
                    event: NutrientEvent.formFieldSelected,
                    data: ["formField": annotationsJSON]
                ) { _ in }
            }
            return
        }

        if externalListeners.contains(.annotationsSelected) {
            let annotationsJSON = PspdfkitFlutterConverter.instantJSON(
                from: annotations)
            nutrientCallback.onEvent(
                event: NutrientEvent.annotationsSelected,
                data: ["annotations": annotationsJSON]
            ) { _ in }
        }
    }

    func annotationDeselected(annotations: [Annotation]) {
        guard !isCleanedUp, let nutrientCallback = nutrientCallback else { return }
        
        if isFormElements(annotations: annotations) {
            if externalListeners.contains(.formFieldDeselected) {
                let annotationsJSON = PspdfkitFlutterConverter.instantJSON(
                    from: annotations)
                nutrientCallback.onEvent(
                    event: NutrientEvent.formFieldDeselected,
                    data: ["formField": annotationsJSON]
                ) { _ in }
            }
            return
        }

        if externalListeners.contains(.annotationsDeselected) {
            let annotationsJSON = PspdfkitFlutterConverter.instantJSON(
                from: annotations)
            nutrientCallback.onEvent(
                event: NutrientEvent.annotationsDeselected,
                data: ["annotations": annotationsJSON]
            ) { _ in }
        }
    }

    func removeEventListener(event: NutrientEvent) {
        // Defensive guard to prevent operations after cleanup
        guard !isCleanedUp else {
            NSLog("FlutterEventsHelper: Attempted to remove event listener after cleanup for event: \(event)")
            return
        }
        
        // Remove stored observer (for events that use block-based observers)
        if let observer = observers[event] {
            NotificationCenter.default.removeObserver(observer)
            observers.removeValue(forKey: event)
        }
        
        // Remove selector-based observer (for events that use selector-based observers)
        if selectorObserverEvents.contains(event) {
            switch event {
            case .annotationsDeleted:
                NotificationCenter.default.removeObserver(
                    self,
                    name: .PSPDFAnnotationsRemoved,
                    object: nil
                )
            case .annotationsUpdated:
                NotificationCenter.default.removeObserver(
                    self,
                    name: .PSPDFAnnotationChanged,
                    object: nil
                )
            default:
                break
            }
            selectorObserverEvents.remove(event)
        }

        // Remove from external listeners
        if externalListeners.contains(event) {
            externalListeners.removeAll { $0 == event }
        }
    }

    func isFormElements(annotations: [Annotation]) -> Bool {
        for annotation in annotations {
            if annotation is FormElement {
                return true
            }
        }
        return false
    }
    
    // MARK: - Comprehensive Cleanup Methods
    
    /// Comprehensive cleanup method that removes all registered observers and external listeners
    /// This method is idempotent and safe to call multiple times
    func cleanupAllListeners() {
        // Prevent multiple cleanup calls
        guard !isCleanedUp else {
            NSLog("FlutterEventsHelper: Cleanup already performed, skipping")
            return
        }
        
        NSLog("FlutterEventsHelper: Starting comprehensive cleanup of all listeners")
        
        // Mark as cleaned up early to prevent race conditions
        isCleanedUp = true
        
        // Remove all stored observers (block-based)
        for (_, observer) in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
        
        // Remove all selector-based observers
        for event in selectorObserverEvents {
            switch event {
            case .annotationsDeleted:
                NotificationCenter.default.removeObserver(
                    self,
                    name: .PSPDFAnnotationsRemoved,
                    object: nil
                )
            case .annotationsUpdated:
                NotificationCenter.default.removeObserver(
                    self,
                    name: .PSPDFAnnotationChanged,
                    object: nil
                )
            default:
                break
            }
        }
        selectorObserverEvents.removeAll()
        
        // Clear external listeners
        externalListeners.removeAll()
        
        // Additional defensive cleanup - remove all observers for this object
        // This catches any observers that might have been missed
        NotificationCenter.default.removeObserver(self)
        
        // Clear callback reference to prevent retain cycles
        nutrientCallback = nil
        
        NSLog("FlutterEventsHelper: Comprehensive cleanup completed successfully")
    }
    
    /// Deinitializer performs final defensive cleanup
    deinit {
        if !isCleanedUp {
            NSLog("FlutterEventsHelper: deinit called without explicit cleanup, performing defensive cleanup")
            // Don't call cleanupAllListeners here as it might cause issues during deallocation
            // Instead, perform minimal cleanup
            observers.removeAll()
            selectorObserverEvents.removeAll()
            externalListeners.removeAll()
            
            // Remove all observers for this instance as a final safety measure
            NotificationCenter.default.removeObserver(self)
            
            nutrientCallback = nil
            isCleanedUp = true
        }
        NSLog("FlutterEventsHelper: deinit completed")
    }

}
