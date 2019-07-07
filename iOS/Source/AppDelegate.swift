//
//  AppDelegate.swift
//  Dome
//
//  Created by Ивлев Александр on 06/07/2019.
//  Copyright © 2019 SIA. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let navController = NavigatrionController()
        let network = Network()
        let storage = Storage()
        network.storage = storage

        navController.network = network
        navController.storage = storage
        
        network.showURLHandler = { [weak navController] url in
            guard let navController = navController else {
                return
            }

            SafariOpenURLHelper.show(on: navController, url: url, animated: true)
        }

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navController

        navController.activate()

        self.window?.makeKeyAndVisible()
        return true
    }

}

