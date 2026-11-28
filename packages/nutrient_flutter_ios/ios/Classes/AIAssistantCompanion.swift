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

/// Bridges `NutrientViewConfiguration.aiAssistantConfiguration` to the Nutrient iOS SDK.
///
/// `PDFConfiguration.aiAssistantSource` and `AIAssistantServerConfiguration` are Swift-only
/// (an enum and a struct), so `NutrientFFI.mm` can't set them through KVC. It calls this class
/// through a forward declaration instead, like `NutrientConflictResolutionCompanion`.
@objc(NutrientAIAssistantCompanion)
public class AIAssistantCompanion: NSObject {

    /// Sets `aiAssistantSource` to `.server(...)` on `builder`.
    ///
    /// Returns `nil` on success, or a warning for the caller to log if the configuration can't be
    /// used. AI Assistant then isn't connected to a server, which would otherwise be silent.
    @objc public static func applyServerConfiguration(
        to builder: PDFConfigurationBuilder,
        serverURL serverURLString: String?,
        jwt: String?,
        sessionID: String?,
        userID: String?
    ) -> String? {
        let values = [("serverUrl", serverURLString), ("jwt", jwt), ("sessionId", sessionID)]
        let missingKeys = values.filter { $0.1?.isEmpty ?? true }.map { $0.0 }
        guard missingKeys.isEmpty, let serverURLString, let jwt, let sessionID else {
            return ignoredConfigurationWarning("is missing \(missingKeys.joined(separator: ", "))")
        }
        guard let serverURL = httpURL(serverURLString) else {
            return ignoredConfigurationWarning("has a serverUrl that isn't an http or https URL: \(serverURLString)")
        }

        let userID = (userID?.isEmpty ?? true) ? nil : userID
        let serverConfiguration = AIAssistantServerConfiguration(serverURL: serverURL, jwt: jwt, sessionID: sessionID, userID: userID)
        builder.aiAssistantSource = .server(serverConfiguration)
        return nil
    }

    /// Whether `configuration` connects AI Assistant to a server, which is what
    /// `aiAssistantConfiguration` sets. The default source, the on-device language model,
    /// returns `false`.
    @objc public static func usesServer(_ configuration: PDFConfiguration) -> Bool {
        if case .server = configuration.aiAssistantSource {
            return true
        }
        return false
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

    private static func ignoredConfigurationWarning(_ problem: String) -> String {
        "aiAssistantConfiguration \(problem), so AI Assistant isn't connected to a server."
    }
}
