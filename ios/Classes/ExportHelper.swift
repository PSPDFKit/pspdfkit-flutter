//
//  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
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
