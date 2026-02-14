//
//  Copyright © 2025 Nutrient. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
import PSPDFKit
import Foundation

// Make sure the class is visible to Objective-C
@objc(AiAssistantHelper)
public class AiAssistantHelper: NSObject {
    
    @objc public static func configureAiAssistant(_ builder: PDFConfigurationBuilder, withOptions map: [String: Any]) {
            let serverUrl = map["serverUrl"] as? String ?? ""
            let jwt = map["jwt"] as? String ?? ""
            let sessionId = map["sessionId"] as? String ?? ""
            let userId = map["userId"] as? String ?? ""

            // If serverUrl or jwt are missing, do not configure the AI Assistant
            if serverUrl.isEmpty || jwt.isEmpty {
                return
            }

        // Safely create URL and handle potential nil case
        guard let serverURL = URL(string: serverUrl) else {
            return
        }
        
        let aiAssistantConfiguration = AIAssistantConfiguration(serverURL: serverURL, jwt: jwt, sessionID: sessionId, userID: userId)
        builder.aiAssistantConfiguration = aiAssistantConfiguration
    }
}
