import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAdFaSAwrxebzkDy6RPvxrXNnUA90id-5o")
    GeneratedPluginRegistrant.register(with: self)
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let factory = ArPlatformViewFactory(messenger: controller.binaryMessenger)
      registrar(forPlugin: "ArPlatformViewPlugin")?
        .register(factory, withId: "outvisionxr/ar_view")
    }

    return result
  }
}
