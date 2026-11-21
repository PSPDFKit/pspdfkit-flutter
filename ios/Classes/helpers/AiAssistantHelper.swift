//
//  Copyright © 2025 Nutrient. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
import PSPDFKit
import PSPDFKitUI
import Foundation

// Make sure the class is visible to Objective-C
@objc(AiAssistantHelper)
public class AiAssistantHelper: NSObject {

    /// Sets the AI Assistant server from the Dart `AIAssistantConfiguration` map
    /// (keys: `serverUrl`, `jwt`, `sessionId`, `userId`).
    ///
    /// If the configuration can't be used, logs a warning and leaves `aiAssistantSource` unset,
    /// so AI Assistant isn't connected to a server, which would otherwise be silent.
    @objc public static func configureAiAssistant(_ builder: PDFConfigurationBuilder, withOptions map: [String: Any]) {
        let serverUrl = map["serverUrl"] as? String ?? ""
        let jwt = map["jwt"] as? String ?? ""
        let sessionId = map["sessionId"] as? String ?? ""
        let userId = map["userId"] as? String ?? ""

        // `sessionId` is optional in the Dart API (sent as an empty string), so only
        // `serverUrl` and `jwt` are required here.
        let missingKeys = [("serverUrl", serverUrl), ("jwt", jwt)].filter { $0.1.isEmpty }.map { $0.0 }
        if !missingKeys.isEmpty {
            logIgnoredConfiguration("is missing \(missingKeys.joined(separator: ", "))")
            return
        }
        guard let serverURL = httpURL(serverUrl) else {
            logIgnoredConfiguration("has a serverUrl that isn't an http or https URL: \(serverUrl)")
            return
        }

        let serverConfiguration = AIAssistantServerConfiguration(serverURL: serverURL, jwt: jwt, sessionID: sessionId, userID: userId.isEmpty ? nil : userId)
        builder.aiAssistantSource = .server(serverConfiguration)
    }

    /// `URL(string:)` accepts almost any string (`localhost:4000`, `not a url`), so this requires
    /// an `http` or `https` scheme and a host.
    private static func httpURL(_ string: String) -> URL? {
        guard let components = URLComponents(string: string),
              let scheme = components.scheme?.lowercased(), scheme == "http" || scheme == "https",
              let host = components.host, !host.isEmpty
        else { return nil }
        return components.url
    }

    private static func logIgnoredConfiguration(_ problem: String) {
        NSLog("[Nutrient] AIAssistantConfiguration %@, so AI Assistant isn't connected to a server.", problem)
    }
}
