import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyD-6SfQ7dWgYzPwgI7LR31oV7AJINjPKUw")
    GeneratedPluginRegistrant.register(with: self)

    // Register AR platform view
    let controller = window?.rootViewController as! FlutterViewController
    let factory = ArPlatformViewFactory(messenger: controller.binaryMessenger)
    registrar(forPlugin: "ArPlatformViewPlugin")!
      .register(factory, withId: "outvisionxr/ar_view")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
