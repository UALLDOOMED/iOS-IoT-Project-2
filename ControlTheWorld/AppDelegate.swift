//
//  AppDelegate.swift
//  ControlTheWorld
//
//  Created by Qiwei Wang on 7/11/19.
//  Copyright © 2019 Qiwei Wang. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var db: Firestore!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        db = Firestore.firestore()
        let authController = Auth.auth()
        authController.signInAnonymously() {
            (authResult, error) in
            guard authResult != nil else {
                fatalError("Firebase auth failed: \(error!)")
            }
        }
        return true
    }
}

