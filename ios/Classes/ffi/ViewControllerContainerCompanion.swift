import Flutter
import UIKit
import PSPDFKit
import PSPDFKitUI

@objc(ViewControllerContainerCompanion)
public class ViewControllerContainerCompanion: NSObject {
  @objc public static func attachViewController(
    viewId: Int64,
    viewController: UnsafeMutableRawPointer
  ) -> Bool {
    return ViewControllerContainerPlatformView.attachViewController(
      viewId,
      viewController
    )
  }
}
