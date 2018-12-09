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
            let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Dropbox.DropboxPhotoWatch")
    
            if let fileURL = containerURL?.appendingPathComponent(filename) {
                
                print("Finding file at URL: \(fileURL)")
            
                if let data = try? Data(contentsOf: fileURL) {
                    print("Image found in cache.")
                    
                    // Display image
                    self.imageView.image = UIImage(data: data)
                    
                } else {
                    print("Image not cached!")
                    
                    let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
                        let fileManager = FileManager.default
                        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        // generate a unique name for this file in case we've seen it before
                        let UUID = Foundation.UUID().uuidString
                        let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
                        return directoryURL.appendingPathComponent(pathComponent)
                    }
                    
                    _ = DropboxClientsManager.authorizedClient!.files.getThumbnail(path: "/\(filename)", format: .png, size: .w640h480, destination: destination).response { response, error in
                        if let (metadata, url) = response {
                            if let data = try? Data(contentsOf: url) {
                                if let image = UIImage(data: data) {
                                    print("Dowloaded file name: \(metadata.name)")
                                    
                                    // Resize image for watch (so it's not huge)
                                    let resizedImage = self.resizeImage(image)
                                    
                                    // Display image
                                    self.imageView.image = resizedImage
                                    
                                    // Save image to local filesystem app group - allows us to access in the watch
                                    let resizedImageData = resizedImage.jpegData(compressionQuality: 1.0)
                                    try? resizedImageData!.write(to: fileURL)
                                }
                            }
                        } else {
                            print("Error downloading file from Dropbox: \(error!)")
                        }
                        
                    }
                }
            }
        } else {
            // No photos in the folder to display.
            print("No photos to display")
            
            self.activityIndicator.isHidden = true
            self.noPhotosLabel.isHidden = false
        }
    }
    
    fileprivate func resizeImage(_ image: UIImage) -> UIImage {

        // Resize and crop to fit Apple watch (square for now, because it's easy)
        let maxSize: CGFloat = 200.0
        var size: CGSize?

        if image.size.width >= image.size.height {
            size = CGSize(width: (maxSize / image.size.height) * image.size.width, height: maxSize)
        } else {
            size = CGSize(width: maxSize, height: (maxSize / image.size.width) * image.size.height)
        }
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size!, !hasAlpha, scale)
        
        let rect = CGRect(origin: CGPoint.zero, size: size!)
        UIRectClip(rect)
        image.draw(in: rect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
}
