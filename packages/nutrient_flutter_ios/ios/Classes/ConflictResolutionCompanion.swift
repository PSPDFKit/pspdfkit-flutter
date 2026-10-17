//
//  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation
import PSPDFKit
import PSPDFKitUI

/// A custom `ConflictResolutionManager` subclass that automatically resolves file
/// conflicts without showing the default alert UI to the user.
///
/// Ported from the legacy `nutrient_flutter` plugin
/// (`PspdfkitApiImpl.AutomaticConflictResolutionManager`). `ConflictResolutionManager`
/// (ObjC: `PSPDFConflictResolutionManager`) does not observe
/// `PSPDFDocumentUnderlyingFileChangedNotification` itself — only
/// `PDFViewController`'s own *private* conflict-resolution machinery does that,
/// routed to a lazily-created private manager instance that this bindings package
/// cannot reach. So `ConflictResolutionCompanion` below registers its own
/// notification observer and forwards matching notifications to an instance of
/// this class via `handleUnderlyingFileChangedNotification(_:)`.
@objc(NutrientAutomaticConflictResolutionManager)
public class AutomaticConflictResolutionManager: ConflictResolutionManager {

    /// The resolution strategy to use when a conflict is detected.
    @objc public var automaticResolution: FileConflictResolution

    @objc public init(resolution: FileConflictResolution) {
        self.automaticResolution = resolution
        super.init()
    }

    /// Automatically resolves file conflicts without showing UI, using
    /// `automaticResolution`. Falls back to the default (UI-presenting)
    /// behavior if the automatic resolution fails.
    @objc public override func handleUnderlyingFileChangedNotification(_ notification: Notification) {
        guard let document = notification.object as? Document,
              let userInfo = notification.userInfo,
              let dataProvider = userInfo["PSPDFDocumentUnderlyingDataProvider"] as? CoordinatedFileDataProviding else {
            return
        }

        do {
            try document.resolveFileConflict(forDataProvider: dataProvider, with: automaticResolution)
        } catch {
            // If automatic resolution fails, fall back to the default UI behavior.
            super.handleUnderlyingFileChangedNotification(notification)
        }
    }
}

/// Bridges `IOSViewConfiguration.fileConflictResolution` to the Nutrient iOS SDK.
///
/// `PDFViewController` doesn't expose a public setter for its conflict-resolution
/// manager (`conflictResolutionManager` is a private, lazily-created property —
/// see `PSPDFViewController.mm`), so this companion independently observes
/// `PSPDFDocumentUnderlyingFileChangedNotification` for the specific `document`
/// registered via `register(resolutionRawValue:for:)`, filtered by object
/// identity (the same check `PDFViewController.underlyingFileChangedNotification:`
/// performs internally), and forwards matching notifications to an
/// `AutomaticConflictResolutionManager`.
///
/// One instance is kept per `PDFViewController` (keyed by
/// `ObjectIdentifier`), created in `register(resolutionRawValue:for:)` and torn
/// down in `unregister(for:)`. Called from `NutrientFFI.mm` via a forward
/// declaration (see the comment atop `NutrientFFI.mm`) rather than a direct
/// Swift import — this file cannot be referenced through the generated Swift
/// bridging header because the native-assets build compiles `NutrientFFI.mm`
/// without it.
@objc(NutrientConflictResolutionCompanion)
public class ConflictResolutionCompanion: NSObject {

    private final class Entry {
        let manager: AutomaticConflictResolutionManager
        var observer: NSObjectProtocol?
        weak var viewController: PDFViewController?

        init(manager: AutomaticConflictResolutionManager) {
            self.manager = manager
        }
    }

    // Keyed by the view controller's ObjectIdentifier so multiple
    // NutrientDocumentView instances (each with its own PDFViewController) get
    // independent conflict-resolution managers.
    private static var entries: [ObjectIdentifier: Entry] = [:]
    private static let lock = NSLock()

    /// Registers automatic file-conflict resolution for `viewController`, using
    /// `resolutionRawValue` (the raw `PSPDFFileConflictResolution` value: 0 =
    /// close, 1 = save, 2 = reload — see `PSPDFFileConflictResolution.h`).
    ///
    /// Safe to call multiple times for the same view controller — a previous
    /// registration is replaced. Must be called on the main thread (matches
    /// `PSPDFAssertMainThread()` in the SDK's own conflict-resolution path).
    ///
    /// - Parameters:
    ///   - resolutionRawValue: Raw `PSPDFFileConflictResolution` value.
    ///   - viewController: The `PDFViewController` (passed as `UIViewController`
    ///     from the ObjC/FFI side) whose document's conflicts should be resolved
    ///     automatically.
    @objc public static func register(resolutionRawValue: UInt, for viewController: UIViewController) {
        guard let pdfViewController = viewController as? PDFViewController,
              let resolution = FileConflictResolution(rawValue: resolutionRawValue) else {
            return
        }

        unregister(for: viewController)

        let manager = AutomaticConflictResolutionManager(resolution: resolution)
        let entry = Entry(manager: manager)
        entry.viewController = pdfViewController

        entry.observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.PSPDFDocumentUnderlyingFileChanged,
            object: nil,
            queue: OperationQueue.main
        ) { [weak pdfViewController] notification in
            // Only handle notifications for the document currently displayed by
            // this view controller — matching identity, not equality, mirrors
            // PDFViewController's own private underlyingFileChangedNotification:
            // handler (checks `document != self.document`).
            guard let pdfViewController = pdfViewController,
                  let notificationDocument = notification.object as? Document,
                  notificationDocument === pdfViewController.document else {
                return
            }
            manager.handleUnderlyingFileChangedNotification(notification)
        }

        lock.lock()
        entries[ObjectIdentifier(pdfViewController)] = entry
        lock.unlock()
    }

    /// Tears down the conflict-resolution observer registered for
    /// `viewController`, if any. Safe to call even when nothing was registered.
    /// Call this when the hosting view is disposed to avoid leaking the
    /// notification observer and the `AutomaticConflictResolutionManager`.
    @objc public static func unregister(for viewController: UIViewController) {
        let key = ObjectIdentifier(viewController)
        lock.lock()
        let entry = entries.removeValue(forKey: key)
        lock.unlock()

        if let observer = entry?.observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
