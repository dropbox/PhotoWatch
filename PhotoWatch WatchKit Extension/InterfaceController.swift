//
//  InterfaceController.swift
//  PhotoWatch WatchKit Extension
//
//  Created by Leah Culver on 5/11/15.
//  Copyright (c) 2015 Dropbox. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Get app group shared by phone and watch
        if let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.Dropbox.DropboxPhotoWatch") {
        
            var names = [String]()
            var contexts = [[String:UIImage]]()
            
            // Fetch all files in the app group
            for item in NSFileManager.defaultManager().contentsOfDirectoryAtURL(containerURL, includingPropertiesForKeys: [NSURLNameKey], options: nil, error: nil) as Array! {
                if let fileURL = item as? NSURL {
        
                    // Check that file is a photo (by file extension)
                    let components = fileURL.absoluteString!.componentsSeparatedByString(".")
                    let ext = components[components.count - 1]
                    
                    if ext == "jpg" || ext == "png" {
                        
                        // Create a PhotoInterfaceController for each photo
                        if let data = NSData(contentsOfURL: fileURL), image = UIImage(data: data) {
                            names.append("PhotoInterfaceController")
                            contexts.append(["image": image])
                        }
                    }
                }
            }
            
            // Update watch display
            WKInterfaceController.reloadRootControllersWithNames(names, contexts: contexts)
        }
    }

}
