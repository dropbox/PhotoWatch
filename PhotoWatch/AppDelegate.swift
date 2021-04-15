//
//  AppDelegate.swift
//  PhotoWatch
//
//  Created by Leah Culver on 5/11/15.
//  Copyright (c) 2015 Dropbox. All rights reserved.
//

import UIKit
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let appKey: String = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        precondition(appKey.count > 0, "Set the appKey of a scoped API App here and in URL Types under the Info tab of the project settings")
        DropboxClientsManager.setupWithAppKey(appKey)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return DropboxClientsManager.handleRedirectURL(url) { authResult in
            guard let authResult = authResult else { return }
            switch authResult {
            case .success(let token):
                print("Success! User is logged into Dropbox with token: \(token)")
            case .cancel:
                print("User canceld OAuth flow.")
            case .error(let error, let description):
                print("Error \(error): \(String(describing: description))")
            }
        }
    }
}

