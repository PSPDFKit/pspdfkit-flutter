import Flutter
import UIKit
import PSPDFKit
import PSPDFKitUI

/// Platform view that hosts a PDFViewController (formerly PSPDFViewController)
/// Similar to Android's FragmentContainerPlatformView
public class ViewControllerContainerPlatformView: NSObject, FlutterPlatformView {
    private let containerView: UIView
    private let viewId: Int64
    private weak var pdfViewController: PDFViewController?
    private var hostingController: UIViewController?

    // Store instances for later access from Dart (similar to Android's Companion)
    private static let instances = NSMapTable<NSNumber, ViewControllerContainerPlatformView>(keyOptions: .strongMemory, valueOptions: .weakMemory)

    init(
        frame: CGRect,
        viewId: Int64,
        messenger: FlutterBinaryMessenger
    ) {
        self.containerView = UIView(frame: frame)
        self.containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.viewId = viewId

        super.init()

        Self.instances.setObject(self, forKey: NSNumber(value: viewId))

        print("[ViewControllerContainer] Created platform view with ID: \(viewId)")
    }

    public func view() -> UIView {
        return containerView
    }

    /// Companion-like static method for attaching a view controller from Dart
    /// Similar to Android's FragmentContainerPlatformView.Companion.attachFragment()
    ///
    /// This method is called from Dart via FFI bindings. It receives a PDFViewController
    /// that was created in Dart using FFI bindings and attaches it to the container.
    ///
    /// - Parameters:
    ///   - viewId: The platform view ID
    ///   - viewController: Pointer to the PDFViewController object (created in Dart via FFI)
    /// - Returns: true if successful, false otherwise
    @objc public static func attachViewController(
        _ viewId: Int64,
        _ viewController: UnsafeMutableRawPointer  // PDFViewController pointer from FFI
    ) -> Bool {
        print("[ViewControllerContainer] Attaching view controller to platform view \(viewId)")

        guard let container = instances.object(forKey: NSNumber(value: viewId)) else {
            print("[ViewControllerContainer] Error: No container found for view ID \(viewId)")
            return false
        }

        // Cast the raw pointer back to a UIViewController (created in Dart via FFI).
        let hostedController = Unmanaged<UIViewController>
            .fromOpaque(viewController)
            .takeUnretainedValue()

        let attach: () -> Bool = {
            if let existingHost = container.hostingController {
                existingHost.willMove(toParent: nil)
                existingHost.view.removeFromSuperview()
                existingHost.removeFromParent()
            }

            guard let flutterViewController = container.findFlutterViewController() else {
                print("[ViewControllerContainer] Error: Could not find Flutter view controller")
                return false
            }

            flutterViewController.addChild(hostedController)
            container.containerView.addSubview(hostedController.view)
            hostedController.view.frame = container.containerView.bounds
            hostedController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hostedController.didMove(toParent: flutterViewController)

            container.hostingController = hostedController
            if let navigationController = hostedController as? UINavigationController {
                container.pdfViewController = navigationController.topViewController as? PDFViewController
                    ?? navigationController.visibleViewController as? PDFViewController
            } else {
                container.pdfViewController = hostedController as? PDFViewController
            }

            print("[ViewControllerContainer] PDF view controller attached successfully")
            return true
        }

        if Thread.isMainThread {
            return attach()
        } else {
            var result = false
            DispatchQueue.main.sync {
                result = attach()
            }
            return result
        }
    }

    private func findFlutterViewController() -> UIViewController? {
        // Get the Flutter view controller through the application's key window
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            print("[ViewControllerContainer] Could not find key window or root view controller")
            return nil
        }
        
        // The root view controller in a Flutter app is typically the FlutterViewController
        if let flutterVC = rootViewController as? FlutterViewController {
            print("[ViewControllerContainer] Found FlutterViewController directly")
            return flutterVC
        }
        
        // If wrapped in a navigation controller or other container, find the Flutter VC
        if let navController = rootViewController as? UINavigationController {
            for vc in navController.viewControllers {
                if let flutterVC = vc as? FlutterViewController {
                    print("[ViewControllerContainer] Found FlutterViewController in navigation stack")
                    return flutterVC
                }
            }
        }
        
        // Try to find any FlutterViewController in the hierarchy
        return findFlutterViewControllerRecursive(from: rootViewController)
    }
    
    private func findFlutterViewControllerRecursive(from viewController: UIViewController) -> UIViewController? {
        if let flutterVC = viewController as? FlutterViewController {
            return flutterVC
        }
        
        for child in viewController.children {
            if let result = findFlutterViewControllerRecursive(from: child) {
                return result
            }
        }
        
        return nil
    }

    deinit {
        print("[ViewControllerContainer] Disposing platform view: \(viewId)")
        Self.instances.removeObject(forKey: NSNumber(value: viewId))
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        hostingController = nil
        pdfViewController = nil
    }
}

/// Factory for creating ViewControllerContainerPlatformView instances
public class ViewControllerContainerFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return ViewControllerContainerPlatformView(
            frame: frame,
            viewId: viewId,
            messenger: messenger
        )
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
