//
//  BackgroundViewController.swift
//  PhotoWatch
//
//  Created by Leah Culver on 5/17/15.
//  Copyright (c) 2015 Dropbox. All rights reserved.
//

import UIKit
import SwiftyDropbox

class BackgroundViewController: UIViewController {
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {

        // Clear the app group of all files
        if let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.Dropbox.DropboxPhotoWatch") {
            
            for item in NSFileManager.defaultManager().contentsOfDirectoryAtURL(containerURL, includingPropertiesForKeys: [NSURLNameKey], options: nil, error: nil) as Array! {
                if let fileURL = item as? NSURL {
                    
                    // Check that file is a photo (by file extension)
                    let components = fileURL.absoluteString!.componentsSeparatedByString(".")
                    let ext = components[components.count - 1]
                    
                    if ext == "jpg" || ext == "png" {
                        
                        // Delete the photo from the app group
                        NSFileManager.defaultManager().removeItemAtURL(fileURL, error: nil)
                    }
                }
            }
        }
        
        // Unlink from Dropbox
        DropboxAuthManager.sharedAuthManager.clearStoredAccessTokens()
        DropboxClient.sharedClient = nil
        
        // Dismiss view controller to show login screen
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}