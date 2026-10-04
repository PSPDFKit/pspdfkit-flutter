import Flutter
import UIKit

public class NutrientFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Register the PDF view controller container platform view
    let pdfViewFactory = ViewControllerContainerFactory(messenger: registrar.messenger())
    registrar.register(pdfViewFactory, withId: "io.nutrient.flutter/pdf_view_controller_container")
  }
}
