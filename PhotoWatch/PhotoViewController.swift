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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noPhotosLabel: UILabel!
    
    var filename: String?
    
    override func viewDidLoad() {
        // Display photo for page
        if let filename = self.filename {
            
            // Get app group shared by phone and watch
            let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.Dropbox.DropboxPhotoWatch")
    
            if let fileURL = containerURL?.URLByAppendingPathComponent(filename) {
                
                print("Finding file at URL: \(fileURL)")
            
                if let data = NSData(contentsOfURL: fileURL) {
                    print("Image found in cache.")
                    
                    // Display image
                    self.imageView.image = UIImage(data: data)
                    
                } else {
                    print("Image not cached!")
                    
                    let destination : (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
                        let fileManager = NSFileManager.defaultManager()
                        let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                        // generate a unique name for this file in case we've seen it before
                        let UUID = NSUUID().UUIDString
                        let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
                        return directoryURL.URLByAppendingPathComponent(pathComponent)
                    }
                    
                    Dropbox.authorizedClient!.files.getThumbnail(path: "/\(filename)", format: .Png, size: .W640h480, destination: destination).response { response, error in
                        if let (metadata, url) = response, data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                            
                            print("Dowloaded file name: \(metadata.name)")
                            
                            // Resize image for watch (so it's not huge)
                            let resizedImage = self.resizeImage(image)
                            
                            // Display image
                            self.imageView.image = resizedImage
                            
                            // Save image to local filesystem app group - allows us to access in the watch
                            let resizedImageData = UIImageJPEGRepresentation(resizedImage, 1.0)
                            resizedImageData!.writeToURL(fileURL, atomically: true)
                            
                        } else {
                            print("Error downloading file from Dropbox: \(error!)")
                        }
                        
                    }
                }
            }
        } else {
            // No photos in the folder to display.
            print("No photos to display")
            
            self.activityIndicator.hidden = true
            self.noPhotosLabel.hidden = false
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
        
        let rect = CGRect(origin: CGPointZero, size: size!)
        UIRectClip(rect)
        image.drawInRect(rect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
}