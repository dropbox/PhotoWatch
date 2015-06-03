//
//  ViewController.swift
//  PhotoWatch
//
//  Created by Leah Culver on 5/11/15.
//  Copyright (c) 2015 Dropbox. All rights reserved.
//

import UIKit
import SwiftyDropbox

class ViewController: UIViewController, UIPageViewControllerDataSource {
    
    var filenames: Array<String>?
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.filenames = []
        
        // Check if the user is logged in
        // If so, display photo view controller
        if let token = DropboxAuthManager.sharedAuthManager.getFirstAccessToken() {
            
            // Set the sharedClient for re-use
            DropboxClient.sharedClient = DropboxClient(accessToken: token)
            
            // Display image background view w/logout button
            let backgroundViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BackgroundViewController") as! UIViewController
            self.presentViewController(backgroundViewController, animated: false, completion: nil)
            
            // List contents of app folder
            DropboxClient.sharedClient.filesListFolder(path: "").response { response, error in
                if let result = response {
                    println("Folder contents:")
                    for entry in result.entries {
                        println(entry.name)
                        
                        // Check that file is a photo (by file extension)
                        if entry.name.hasSuffix(".jpg") || entry.name.hasSuffix(".png") {
                            // Add photo!
                            self.filenames?.append(entry.name)
                        }
                    }
                    
                    // Show page view controller for photos
                    let pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
                    pageViewController.dataSource = self
                    
                    // Display the first photo screen
                    if self.filenames != nil {
                        let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController
                        photoViewController.filename = self.filenames![0]
                        pageViewController.setViewControllers([photoViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
                    }
                    
                    // Change the size of page view controller
                    pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
                    
                    // Display the page view controller on top of background view controller
                    backgroundViewController.addChildViewController(pageViewController)
                    backgroundViewController.view.addSubview(pageViewController.view)
                    pageViewController.didMoveToParentViewController(self)
                    
                } else {
                    println("Error: \(error!)")
                }
            }
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let currentViewController = viewController as! PhotoViewController
        var nextIndex = 0
        
        if let index = find(self.filenames!, currentViewController.filename!) {
            if index < self.filenames!.count - 1 {
                nextIndex = index + 1
            }
        }
        
        let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController
        photoViewController.filename = self.filenames![nextIndex]

        return photoViewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let currentViewController = viewController as! PhotoViewController
        var nextIndex = self.filenames!.count - 1
        
        if let index = find(self.filenames!, currentViewController.filename!) {
            if index > 0 {
                nextIndex = index - 1
            }
        }
        
        let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController
        photoViewController.filename = self.filenames![nextIndex]
        
        return photoViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        // Number of pages is number of photos
        return self.filenames!.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

    @IBAction func linkButtonPressed(sender: AnyObject) {
        // Present view to log in
        Dropbox.authorizeFromController(self)
    }
}

