//
//  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import PSPDFKit

class FlutterAnalyticsClient: PDFAnalyticsClient {
    
    private var analyticsEventsCallback: AnalyticsEventsCallback? = nil
    
    init(analyticsEventsCallback: AnalyticsEventsCallback) {
        self.analyticsEventsCallback = analyticsEventsCallback
    }

    func logEvent(_ event: PDFAnalytics.EventName, attributes: [String: Any]?) {
        DispatchQueue.main.async { [weak self] in
            self?.analyticsEventsCallback?.onEvent(event: event.rawValue, attributes: attributes){_ in }
        }
    }
}
