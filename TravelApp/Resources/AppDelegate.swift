//
//  AppDelegate.swift
//  TravelApp
//
//  Created by Şükrü Özkoca on 4.03.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            let view = UIView(frame: UIApplication.shared.statusBarFrame)
            view.backgroundColor = UIColor.black
            view.alpha = 0.4
            self.window?.addSubview(view)
            self.window?.bringSubviewToFront(view)
        }

        var config = ElongationConfig()
        config.scaleViewScaleFactor = 0.9
        config.topViewHeight = 190
        config.bottomViewHeight = 170
        config.bottomViewOffset = 20
        config.parallaxFactor = 100
        config.separatorHeight = 0.5
        config.separatorColor = UIColor.white
        config.detailPresentingDuration = 0.4
        config.detailDismissingDuration = 0.4
        config.headerTouchAction = .collpaseOnBoth
        ElongationConfig.shared = config

        return true
    }
}

