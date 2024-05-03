//
//  ExportHelper.swift
//  pspdfkit_flutter
//  Created by Julius Kato on 29/04/2024.
//

import Foundation
import PSPDFKit.PSPDFProcessor
import PSPDFKit

@objc public class DocumentExportHelper: NSObject {
    
    static func extractPermissions(permissions:Array<String>) -> Array<DocumentPermissions>? {
        var permissionsArray = Array<DocumentPermissions>()
        for permissionString in permissions {
            switch permissionString {
            case "print":
                permissionsArray.append(.printing)
            case "modification":
                permissionsArray.append(.modification)
            case "extractAccessibility":
                permissionsArray.append(.extractAccessibility)
            case "fillForms":
                permissionsArray.append(.fillForms)
            case "extract":
                permissionsArray.append(.extract)
            case "assemble":
                permissionsArray.append(.assemble)
            case "printHighResolution":
                permissionsArray.append(.printHighQuality)
            case "annotationsAndForms":
                permissionsArray.append(.annotationsAndForms)
            default:
                continue
            }
        }
        return permissionsArray
    }
}
