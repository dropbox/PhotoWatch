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

    override func awake(withContext context: Any?) {
        // Get images from the shared app group
        if let images = self.getImagesFromAppGroup() {
            
            if images.count > 0 {

                // Data for each photo view
                let controllerNames = [String](repeating: "PhotoInterfaceController", count: images.count)
                let contexts = images.map({ image in ["image": image] })
                
                // Update watch display
                WKInterfaceController.reloadRootControllers(withNames: controllerNames, contexts: contexts)
            }
        }
    }
    
    fileprivate func getImagesFromAppGroup() -> Array<UIImage>? {
        var images = [UIImage]()
        
        // Get app group shared by phone and watch
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Dropbox.DropboxPhotoWatch") {
        
            // Fetch all files in the app group
            do {
                let fileURLArray = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: [URLResourceKey.nameKey], options: [])
                
                for fileURL in fileURLArray {
                    // Check that file is a photo (by file extension)
                    print("Finding file at URL: \(fileURL)")
                    
                    if fileURL.absoluteString.hasSuffix(".jpg") || fileURL.absoluteString.hasSuffix(".png") {
                        
                        // Add image to array of images
                        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
                            images.append(image)
                        }
                    }
                    
                }
            } catch _ as NSError {
                // Do nothing with the error
            }
        }
        
        return images
    }

}
