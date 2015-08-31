//
//  PhotoViewController.swift
//  PhotoWatch
//
//  Created by Leah Culver on 5/14/15.
//  Copyright (c) 2015 Dropbox. All rights reserved.
//

import UIKit
import ImageIO
import SwiftyDropbox

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!

    var filename: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display photo for page
        if let filename = self.filename {
            
            // Get app group shared by phone and watch
            let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.Dropbox.DropboxPhotoWatch")
    
            if let fileURL = containerURL?.URLByAppendingPathComponent(filename) {
                
                println("Finding file at URL: \(fileURL)")
            
                if let data = NSData(contentsOfURL: fileURL) {
                    println("Image found in cache.")
                    
                    // Display image
                    self.imageView.image = UIImage(data: data)
                    
                } else {
                    println("Image not cached!")
                    
                    // Download the photo from Dropbox
                    // A thumbnail would be better but there's no endpoint for that in API v2 yet!
                    Dropbox.authorizedClient!.filesDownload(path: "/\(filename)").response { response, error in
                        
                        if let (metadata, data) = response, image = UIImage(data: data) {
                                
                            println("Dowloaded file name: \(metadata.name)")
                            
                            // Resize image for watch (so it's not huge)
                            let resizedImage = self.resizeImage(image)
                            
                            // Display image
                            self.imageView.image = resizedImage
                            
                            // Save image to local filesystem app group - allows us to access in the watch
                            let resizedImageData = UIImageJPEGRepresentation(resizedImage, 1.0)
                            resizedImageData.writeToURL(fileURL, atomically: true)
                            
                        } else {
                            println("Error downloading file from Dropbox: \(error!)")
                        }
                    }
                }
            }
        } else {
            println("No photos to display")
        }
    }
    
    private func resizeImage(image: UIImage) -> UIImage {

        // Resize and crop to fit Apple watch (square for now, because it's easy)
        let maxSize: CGFloat = 200.0
        var size: CGSize?

        if image.size.width >= image.size.height {
            size = CGSizeMake((maxSize / image.size.height) * image.size.width, maxSize)
        } else {
            size = CGSizeMake(maxSize, (maxSize / image.size.width) * image.size.height)
        }
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size!, !hasAlpha, scale)
        
        var rect = CGRect(origin: CGPointZero, size: size!)
        UIRectClip(rect)
        image.drawInRect(rect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
}