//
//  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
import PSPDFKit
import Foundation

// Make sure the class is visible to Objective-C
@objc(SignatureHelper)
public class SignatureHelper: NSObject {
    
    /// Configures the signature creation settings on a PSPDFConfiguration builder from Flutter parameters
    /// - Parameters:
    ///   - builder: The PSPDFConfigurationBuilder to modify
    ///   - map: Dictionary containing signature configuration parameters
    @objc public static func configureSignatureCreation(_ builder: PDFConfigurationBuilder, withOptions map: [String: Any]) {
        // Default values
        var availableModes: [SignatureCreationViewController.Mode] = [.draw, .image, .type]
        var colors: [UIColor] = SignatureCreationViewController.Configuration.defaultColors
        var signatureFonts: [UIFont] = SignatureCreationViewController.Configuration.defaultFonts
        var signatureAspectRatio: CGFloat = 1.5
        
        // Set creation modes if available
        if let creationModes = map["creationModes"] as? [String] {
            availableModes = creationModesFromStrings(creationModes)
        }
        
        // Set color options if available
        if let colorOptions = map["colorOptions"] as? [String: Any] {
            colors = colorOptionsFromMap(colorOptions)
        }
        
        // Set iOS aspect ratio if available
        if let aspectRatio = map["iosSignatureAspectRatio"] as? Double {
            signatureAspectRatio = CGFloat(aspectRatio)
        }
        
        // Set fonts if available
        if let fontNames = map["fonts"] as? [String] {
            let convertedFonts = fontsFromStringArray(fontNames)
            if !convertedFonts.isEmpty {
                signatureFonts = convertedFonts
            }
        }
        
        // Create the configuration and apply it to the builder
        let signatureConfig = SignatureCreationViewController.Configuration(
            availableModes: availableModes,
            colors: colors,
            isNaturalDrawingEnabled: true,
            fonts: signatureFonts,
            signingAreaAspectRatio: signatureAspectRatio
        )
        
        // Apply the configuration to the builder
        builder.signatureCreationConfiguration = signatureConfig
    }
    
    /// Converts an array of creation mode strings to a set of SignatureCreationViewController.Mode values
    /// - Parameter modes: Array of mode strings ("draw", "image", "type")
    /// - Returns: Set of SignatureCreationViewController.Mode values
    private static func creationModesFromStrings(_ modes: [String]) -> [SignatureCreationViewController.Mode] {
        var creationModes = [SignatureCreationViewController.Mode]()
        
        for mode in modes {
            switch mode {
            case "draw":
                creationModes.append(.draw)
            case "image":
                creationModes.append(.image)
            case "type":
                creationModes.append(.type)
            default:
                break
            }
        }
        return creationModes
    }
    
    private static func fontsFromStringArray(_ fontNames: [String]) -> [UIFont] {
        var fonts = [UIFont]()
        
        for fontName in fontNames {
            if let font = UIFont(name: fontName, size: 32.0) {
                fonts.append(font)
            }
        }
        // If no valid fonts were found, return an empty array
        // The caller will use default fonts in this case
        return fonts
    }
 
    @objc private static func colorOptionsFromMap(_ colorOptionsMap: [String: Any]) -> [UIColor] {
        var option1 = UIColor.black
        var option2 = UIColor.blue
        var option3 = UIColor.red
        
        // Extract option1
        if let option1Map = colorOptionsMap["option1"] as? [String: Any],
           let colorHex = option1Map["color"] as? String {
            option1 = UIColor(hex: colorHex) ?? UIColor.black
        }
        
        // Extract option2
        if let option2Map = colorOptionsMap["option2"] as? [String: Any],
           let colorHex = option2Map["color"] as? String {
            option2 = UIColor(hex: colorHex) ?? UIColor.blue
        }
        
        // Extract option3
        if let option3Map = colorOptionsMap["option3"] as? [String: Any],
           let colorHex = option3Map["color"] as? String {
            option3 = UIColor(hex: colorHex) ?? UIColor.red
        }
        
        return [option1, option2, option3]
    }
}

// Extension to convert hex string to UIColor
extension UIColor {
    @objc convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 1.0
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            } else if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
