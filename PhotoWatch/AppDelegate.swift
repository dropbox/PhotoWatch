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


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        DropboxAuthManager.sharedAuthManager = DropboxAuthManager(appKey: "rco93k6ms9h0okt")
        
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        if let authResult = DropboxAuthManager.sharedAuthManager.handleRedirectURL(url) {
            switch authResult {
            case .Success(let token):
                println("Success! User is logged into Dropbox.")
            case .Error(let error, let description):
                println("Error: \(description)")
            }
        }
        
        return false
    }
    

}

