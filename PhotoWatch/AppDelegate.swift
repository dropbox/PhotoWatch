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
        
        Dropbox.setupWithAppKey("rco93k6ms9h0okt")
        
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        if let authResult = Dropbox.handleRedirectURL(url) {
            switch authResult {
            case .Success(let token):
                print("Success! User is logged into Dropbox with token: \(token)")
            case .Cancel:
                print("User canceld OAuth flow.")
            case .Error(let error, let description):
                print("Error \(error): \(description)")
            }
        }
        
        return false
    }
    

}

