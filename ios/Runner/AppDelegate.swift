import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Read API key from .env file bundled in assets
    if let envPath = Bundle.main.path(forResource: "flutter_assets/.env", ofType: nil),
       let contents = try? String(contentsOfFile: envPath, encoding: .utf8) {
        let lines = contents.components(separatedBy: .newlines)
        for line in lines {
            let parts = line.components(separatedBy: "=")
            if parts.count >= 2, parts[0].trimmingCharacters(in: .whitespacesAndNewlines) == "GOOGLE_MAPS_API_KEY" {
                let apiKey = parts[1...].joined(separator: "=").trimmingCharacters(in: .whitespacesAndNewlines)
                if !apiKey.isEmpty {
                    GMSServices.provideAPIKey(apiKey)
                }
            }
        }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
