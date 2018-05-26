import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        let controller = window?.rootViewController as! FlutterViewController
        let iosChannel = FlutterMethodChannel.init(name: "com.msasikanth.newsapp/ios", binaryMessenger: controller)
    
        iosChannel.setMethodCallHandler { (methodCall, result) in
            if methodCall.method == "launchUrl" {
                let arguments = methodCall.arguments as! Dictionary<String, Any>
                self.launchUrl(url: arguments["url"] as! String)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func launchUrl(url: String) {
        guard let url = URL(string: url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}
