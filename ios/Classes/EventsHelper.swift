//
//  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
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

    public init(nutrientCallback: NutrientEventsCallbacks?) {
        self.nutrientCallback = nutrientCallback
        super.init()
    }

    func setEventListener(event: NutrientEvent) {
        switch event {
        case .annotationsCreated:
            let observer = NotificationCenter.default.addObserver(
                forName: .PSPDFAnnotationsAdded,
                object: nil,
                queue: nil
            ) { [weak self] notification in
                self?.annotationsAddedNotification(notification: notification)
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
            break
        case .annotationsUpdated:
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(
                    annotationChangedNotification(notification:)),
                name: .PSPDFAnnotationChanged,
                object: nil)
            break
        case .annotationsSelected:
            externalListeners.append(event)
            break
        case .annotationsDeselected:
            externalListeners.append(event)
            break
        case .textSelectionChanged:
            externalListeners.append(event)
            break
        case .formFieldValuesUpdated:
            let observer = NotificationCenter.default.addObserver(
                forName: .PSPDFAnnotationChanged,
                object: nil,
                queue: nil
            ) { [weak self] notification in
                self?.formFieldValueChangedNotification(
                    notification: notification)
            }
            observers[event] = observer
            break
        case .formFieldSelected:
            externalListeners.append(event)
            break
        case .formFieldDeselected:
            externalListeners.append(event)
            break
        }
    }

    @objc func annotationsAddedNotification(notification: Notification) {
        if let annotations = notification.object as? [Annotation] {
            let annotationJSON = PspdfkitFlutterConverter.instantJSON(
                from: annotations)
            nutrientCallback?.onEvent(
                event: NutrientEvent.annotationsCreated,
                data: ["annotations": annotationJSON]
            ) { _ in }
        }
    }

    @objc func annotationsRemovedNotification(notification: Notification) {
        if let annotations = notification.object as? [Annotation] {
            let annotationJSON = PspdfkitFlutterConverter.instantJSON(
                from: annotations)
            nutrientCallback?.onEvent(
                event: NutrientEvent.annotationsDeleted,
                data: ["annotations": annotationJSON]
            ) { _ in }
        }
    }

    @objc func annotationChangedNotification(notification: Notification) {
        if let annotation = notification.object as? Annotation {
            let annotationJSON = PspdfkitFlutterConverter.instantJSON(from: [
                annotation
            ])
            nutrientCallback?.onEvent(
                event: NutrientEvent.annotationsUpdated,
                data: ["annotations": annotationJSON]
            ) { _ in }
        }
    }

    @objc func formFieldValueChangedNotification(notification: Notification) {
        // Check if the notification object is a FormElement.
        guard let annotation = notification.object as? [FormElement] else {
            return
        }
        let annotationJSON = PspdfkitFlutterConverter.instantJSON(
            from: annotation)
        nutrientCallback?.onEvent(
            event: NutrientEvent.formFieldValuesUpdated,
            data: ["formField": annotationJSON]
        ) { _ in }
    }

    @objc func textSelected(text: String, glyphs: [Glyph], rect: CGRect) {
        if externalListeners.contains(.textSelectionChanged) {
            nutrientCallback?.onEvent(
                event: NutrientEvent.textSelectionChanged, data: ["text": text]
            ) { _ in }
        }
    }

    func annotationSelected(annotations: [Annotation]) {
        if isFormElements(annotations: annotations) {
            if externalListeners.contains(.formFieldSelected) {
                let annotationsJSON = PspdfkitFlutterConverter.instantJSON(
                    from: annotations)
                nutrientCallback?.onEvent(
                    event: NutrientEvent.formFieldSelected,
                    data: ["formField": annotationsJSON]
                ) { _ in }
            }
            return
        }

        if externalListeners.contains(.annotationsSelected) {
            let annotationsJSON = PspdfkitFlutterConverter.instantJSON(
                from: annotations)
            nutrientCallback?.onEvent(
                event: NutrientEvent.annotationsSelected,
                data: ["annotations": annotationsJSON]
            ) { _ in }
        }
    }

    func annotationDeselected(annotations: [Annotation]) {
        if isFormElements(annotations: annotations) {
            if externalListeners.contains(.formFieldDeselected) {
                let annotationsJSON = PspdfkitFlutterConverter.instantJSON(
                    from: annotations)
                nutrientCallback?.onEvent(
                    event: NutrientEvent.formFieldDeselected,
                    data: ["formField": annotationsJSON]
                ) { _ in }
            }
            return
        }

        if externalListeners.contains(.annotationsDeselected) {
            let annotationsJSON = PspdfkitFlutterConverter.instantJSON(
                from: annotations)
            nutrientCallback?.onEvent(
                event: NutrientEvent.annotationsDeselected,
                data: ["annotations": annotationsJSON]
            ) { _ in }
        }
    }

    func removeEventListener(event: NutrientEvent) {
        if let observer = observers[event] {
            NotificationCenter.default.removeObserver(observer)
            observers.removeValue(forKey: event)
        }

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

}
