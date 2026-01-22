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
import PSPDFKitUI

/// Helper class for managing custom annotation contextual menus in PSPDFKit
@objc class AnnotationMenuHelper: NSObject {
    
    /// Configuration data for annotation menus
    private static var menuConfiguration: AnnotationMenuConfigurationData?
    
    
    /// Currently selected annotations for menu context
    private static var selectedAnnotations: [Annotation] = []
    
    /// Maps AnnotationMenuAction enum values to PSPDFKit action identifier patterns (static version for external access)
    static func getActionIdentifiersStatic(for action: AnnotationMenuAction) -> [String] {
        return getActionIdentifiers(for: action)
    }
    
    /// Maps AnnotationMenuAction enum values to PSPDFKit action identifier patterns and title patterns
    private static func getActionIdentifiers(for action: AnnotationMenuAction) -> [String] {
        switch action {
        case .delete:
            // PSPDFKit and iOS system delete action identifiers and titles
            return ["delete", "remove", "trash", "Delete", "Remove"]
        case .copy:
            return ["copy", "duplicate", "Copy", "Duplicate"]
        case .cut:
            return ["cut", "Cut"]
        case .color:
            return ["color", "style", "picker", "inspector", "Color", "Style", "Picker", "Inspector", "Appearance"]
        case .note:
            return ["note", "comment", "Note", "Comment"]
        case .undo:
            return ["undo", "Undo"]
        case .redo:
            return ["redo", "Redo"]
        default:
            return []
        }
    }
    
    /// Sets up annotation menu configuration (used during initialization)
    /// - Parameters:
    ///   - configuration: The annotation menu configuration from Flutter
    static func setupAnnotationMenu(configuration: AnnotationMenuConfigurationData?) {
        self.menuConfiguration = configuration
        
        // Configuration setup complete
    }
    
    /// Updates the annotation menu configuration dynamically
    /// - Parameter configuration: The new annotation menu configuration
    static func updateConfiguration(configuration: AnnotationMenuConfigurationData?) {
        self.menuConfiguration = configuration
        
        // Configuration updated
    }
    
    /// Updates the currently selected annotations for menu context
    /// - Parameter annotations: The currently selected annotations
    static func updateSelectedAnnotations(_ annotations: [Annotation]) {
        self.selectedAnnotations = annotations
    }
    
    /// Creates a custom contextual menu for the selected annotation
    /// - Parameters:
    ///   - annotation: The annotation to create a menu for
    ///   - defaultActions: The default PSPDFKit menu actions
    /// - Returns: A configured UIMenu with custom and default items
    @available(iOS 13.0, *)
    static func createContextualMenu(for annotation: Annotation, defaultActions: [UIMenuElement]) -> UIMenu? {
        // Check if we have a configuration
        guard let config = menuConfiguration else {
            return UIMenu(title: "", children: defaultActions)
        }
        
        let filteredActions = filterMenuElements(defaultActions, config: config)
        
        return UIMenu(title: "", children: filteredActions)
    }
    
    /// Recursively filters menu elements based on the configuration
    /// - Parameters:
    ///   - elements: The menu elements to filter
    ///   - config: The annotation menu configuration
    /// - Returns: Filtered array of menu elements
    @available(iOS 13.0, *)
    private static func filterMenuElements(_ elements: [UIMenuElement], config: AnnotationMenuConfigurationData) -> [UIMenuElement] {
        return elements.compactMap { element -> UIMenuElement? in
            if let action = element as? UIAction {
                // Check if this action should be removed
                if shouldRemoveAction(action, config: config) {
                    return nil
                }
                
                // Check if this action should be disabled
                if let disabledAction = getDisabledActionIfNeeded(action, config: config) {
                    return disabledAction
                }
                
                return action
                
            } else if let menu = element as? UIMenu {
                // Recursively filter submenu items
                let filteredChildren = filterMenuElements(menu.children, config: config)
                if !filteredChildren.isEmpty {
                    return UIMenu(title: menu.title, image: menu.image, identifier: menu.identifier, 
                                options: menu.options, children: filteredChildren)
                } else {
                    return nil
                }
            }
            
            return element
        }
    }
    
    /// Determines if an action should be removed based on configuration
    /// - Parameters:
    ///   - action: The UIAction to check
    ///   - config: The annotation menu configuration
    /// - Returns: True if the action should be removed
    @available(iOS 13.0, *)
    private static func shouldRemoveAction(_ action: UIAction, config: AnnotationMenuConfigurationData) -> Bool {
        let title = action.title
        let identifier = action.identifier.rawValue
        
        // Check against items to remove
        for itemToRemove in config.itemsToRemove {
            if matchesAction(title: title, identifier: identifier, action: itemToRemove) {
                return true
            }
        }
        
        // Check style picker visibility
        if !config.showStylePicker && isStylePickerAction(title: title, identifier: identifier) {
            return true
        }
        
        return false
    }
    
    /// Creates a disabled version of an action if it should be disabled
    /// - Parameters:
    ///   - action: The UIAction to check
    ///   - config: The annotation menu configuration
    /// - Returns: A disabled UIAction if the action should be disabled, nil otherwise
    @available(iOS 13.0, *)
    private static func getDisabledActionIfNeeded(_ action: UIAction, config: AnnotationMenuConfigurationData) -> UIAction? {
        let title = action.title
        let identifier = action.identifier.rawValue
        
        // Check against items to disable
        for itemToDisable in config.itemsToDisable {
            if matchesAction(title: title, identifier: identifier, action: itemToDisable) {
                let disabledAction = UIAction(title: action.title, image: action.image) { _ in
                    // No action for disabled items
                }
                disabledAction.attributes = .disabled
                return disabledAction
            }
        }
        
        return nil
    }
    
    /// Checks if a title/identifier matches a specific annotation menu action
    /// - Parameters:
    ///   - title: The action title
    ///   - identifier: The action identifier
    ///   - action: The AnnotationMenuAction to match against
    /// - Returns: True if the title or identifier matches the action
    private static func matchesAction(title: String, identifier: String, action: AnnotationMenuAction) -> Bool {
        let patterns = getActionIdentifiers(for: action)
        let titleLower = title.lowercased()
        let identifierLower = identifier.lowercased()
        
        for pattern in patterns {
            let patternLower = pattern.lowercased()
            
            // Exact match
            if titleLower == patternLower || identifierLower == patternLower {
                return true
            }
            
            // Word boundary match for titles (avoid partial matches)
            if isWordBoundaryMatch(text: titleLower, pattern: patternLower) {
                return true
            }
            
            // Identifier suffix match (e.g., "com.example.delete" matches "delete")
            if identifierLower.hasSuffix("." + patternLower) {
                return true
            }
        }
        
        return false
    }
    
    /// Checks if a pattern matches as a complete word within the text
    /// - Parameters:
    ///   - text: The text to search in
    ///   - pattern: The pattern to search for
    /// - Returns: True if the pattern matches as a complete word
    private static func isWordBoundaryMatch(text: String, pattern: String) -> Bool {
        // Use NSRegularExpression for proper word boundary matching
        do {
            let regex = try NSRegularExpression(pattern: "\\b" + NSRegularExpression.escapedPattern(for: pattern) + "\\b", options: .caseInsensitive)
            let range = NSRange(location: 0, length: text.utf16.count)
            return regex.firstMatch(in: text, options: [], range: range) != nil
        } catch {
            // Fallback to simple containment if regex fails
            return text.contains(pattern)
        }
    }
    
    /// Checks if an action is related to the style picker
    /// - Parameters:
    ///   - title: The action title
    ///   - identifier: The action identifier
    /// - Returns: True if the action is style picker related
    private static func isStylePickerAction(title: String, identifier: String) -> Bool {
        return matchesAction(title: title, identifier: identifier, action: .color)
    }
    
    
    
    /// Determines if an annotation should show custom contextual menu
    /// - Parameter annotation: The annotation to check
    /// - Returns: True if custom menu should be shown
    static func shouldShowCustomMenu(for annotation: Annotation) -> Bool {
        return menuConfiguration != nil
    }
    
    /// Gets the current annotation menu configuration
    /// - Returns: The current configuration, if any
    static func getCurrentConfiguration() -> AnnotationMenuConfigurationData? {
        return menuConfiguration
    }
    
    /// Cleans up annotation menu resources
    static func cleanup() {
        menuConfiguration = nil
        selectedAnnotations.removeAll()
    }
}

// MARK: - Menu Identifiers

/// Common PSPDFKit menu item identifiers for reference
private enum PSPDFMenuIdentifier {
    static let copy = "Copy"
    static let delete = "Delete"
    static let duplicate = "Duplicate"
    static let style = "Style"
    static let note = "Note"
    static let highlight = "Highlight"
    static let underline = "Underline"
    static let strikeout = "Strikeout"
    static let squiggly = "Squiggly"
    static let edit = "Edit"
    static let remove = "Remove"
    static let inspector = "Inspector"
}