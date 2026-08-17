import SwiftUI
import UIKit
import AppsFlyerLib
import FirebaseCore

@UIApplicationMain
final class AppDelegate: NSObject, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()

        AppsFlyerLib.shared().initialize(devKey: "KeF3FqoX7p69SWFoQ5eEiJ", appId: "6794929904")
        AppsFlyerLib.shared().delegate = self

        let rootView = LaunchRootView()
            .preferredColorScheme(.dark)

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: rootView)
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().start()
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        let campaign = conversionInfo["c"] as? String ?? conversionInfo["campaign"] as? String ?? ""
        UserDefaults.standard.setValue(campaign, forKey: "capMeta")
        UserDefaults.standard.setValue(true, forKey: "capReady")
    }

    func onConversionDataFail(_ error: Error) {
        UserDefaults.standard.setValue("", forKey: "capMeta")
        UserDefaults.standard.setValue(true, forKey: "capReady")
    }
}
