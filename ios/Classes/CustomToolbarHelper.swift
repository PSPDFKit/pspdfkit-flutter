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

@objc class CustomToolbarHelper: NSObject {
    private static var customToolbarItems = [String: UIBarButtonItem]()
    private static weak var callbacksRef: CustomToolbarCallbacks?

    /// Sets up custom toolbar items in the PDF view controller
    /// - Parameters:
    ///   - pdfViewController: The PDF view controller
    ///   - customToolbarItems: Array of custom toolbar items
    ///   - callbacks: The callbacks instance to notify when a custom toolbar item is tapped
    static func setupCustomToolbarItems(for pdfViewController: PDFViewController, customToolbarItems: [[String: Any]], callbacks: CustomToolbarCallbacks?) {
        guard !customToolbarItems.isEmpty else { return }

        // Store callbacks reference
        self.callbacksRef = callbacks

        // Clean up existing custom items
        self.customToolbarItems.removeAll()

        // Get existing bar button items
        var leftItems = pdfViewController.navigationItem.leftBarButtonItems ?? []
        var rightItems = pdfViewController.navigationItem.rightBarButtonItems ?? []

        for itemConfig in customToolbarItems {
            guard let identifier = itemConfig["identifier"] as? String, !identifier.isEmpty,
                  let title = itemConfig["title"] as? String, !title.isEmpty else {
                continue
            }

            // Create a toolbar button with selector action
            let buttonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(customToolbarItemTapped(_:)))

            // Configure icon if available
            configureIcon(for: buttonItem, from: itemConfig)

            // Store the identifier with the button using objc_setAssociatedObject
            objc_setAssociatedObject(buttonItem, UnsafeRawPointer(bitPattern: 1)!, identifier, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            // Store the button for later reference
            self.customToolbarItems[identifier] = buttonItem

            // Determine the position of the item
            let positionStr = itemConfig["position"] as? String ?? "primary"
            
            // Add to appropriate toolbar position based on position property
            if positionStr == "iosLeft" {
                // Add to left side of navigation bar
                leftItems.append(buttonItem)
            } else {
                // Default to right side for all other positions (primary, secondary, iosRight)
                rightItems.append(buttonItem)
            }
        }

        // Update the navigation bar with both left and right items
        pdfViewController.navigationItem.setLeftBarButtonItems(leftItems, animated: true)
        pdfViewController.navigationItem.setRightBarButtonItems(rightItems, animated: true)
    }

    /// Configures the icon for a toolbar button item
    /// - Parameters:
    ///   - buttonItem: The button item to configure
    ///   - config: The configuration dictionary for the item
    private static func configureIcon(for buttonItem: UIBarButtonItem, from config: [String: Any]) {
        if let iconName = config["iconName"] as? String, !iconName.isEmpty {
            var iconImage: UIImage? = nil
            
            // Search order priority:
            // 1. Asset catalog images (app bundle)
            // 2. SF Symbols (system icons)
            // 3. Fallback to text if no icon found
            
            // First try to find the icon in the app's asset catalog
            if let bundleImage = UIImage(named: iconName) {
                iconImage = bundleImage
            }
            // Next try SF Symbols (iOS 13+)
            else if let systemImage = UIImage(systemName: iconName) {
                iconImage = systemImage
            }

            // If we found an image, apply it
            if let image = iconImage {
                buttonItem.image = image
                buttonItem.title = nil

                // Apply icon color if specified
                if let iconColorHex = config["iconColor"] as? String, !iconColorHex.isEmpty {
                    if let color = UIColor(hexString: iconColorHex) {
                        buttonItem.tintColor = color
                    }
                }
            }
        }
    }

    /// Handler for custom toolbar item taps
    /// - Parameter sender: The button that was tapped
    @objc static func customToolbarItemTapped(_ sender: UIBarButtonItem) {
        // Retrieve the identifier
        if let identifier = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: 1)!) as? String {
            // Notify Flutter about the tap
            callbacksRef?.onCustomToolbarItemTapped(identifier: identifier) { _ in }
        }
    }
}
