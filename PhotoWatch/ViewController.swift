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
        self.filenames = []
        
        // Check if the user is logged in
        // If so, display photo view controller
        if let client = Dropbox.authorizedClient {
            
            // Display image background view w/logout button
            let backgroundViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BackgroundViewController") as UIViewController!
            self.presentViewController(backgroundViewController, animated: false, completion: nil)
            
            // List contents of app folder
            client.files.listFolder(path: "").response { response, error in
                if let result = response {
                    print("Folder contents:")
                    for entry in result.entries {
                        print(entry.name)
                        
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
                        photoViewController.filename = self.filenames!.first
                        pageViewController.setViewControllers([photoViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
                    }
                    
                    // Change the size of page view controller
                    pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
                    
                    // Display the page view controller on top of background view controller
                    backgroundViewController.addChildViewController(pageViewController)
                    backgroundViewController.view.addSubview(pageViewController.view)
                    pageViewController.didMoveToParentViewController(self)
                    
                } else {
                    print("Error: \(error!)")
                }
            }
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if self.filenames != nil {
            let currentViewController = viewController as! PhotoViewController
            var nextIndex = 0
            
            if let index = self.filenames!.indexOf(currentViewController.filename!) {
                if index < self.filenames!.count - 1 {
                    nextIndex = index + 1
                }
            }
            
            let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController
            photoViewController.filename = self.filenames![nextIndex]
            
            return photoViewController
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if self.filenames != nil {
            let currentViewController = viewController as! PhotoViewController
            var nextIndex = self.filenames!.count - 1
            
            if let index = self.filenames!.indexOf(currentViewController.filename!) {
                if index > 0 {
                    nextIndex = index - 1
                }
            }
            
            let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController
            photoViewController.filename = self.filenames![nextIndex]
            
            return photoViewController
        }
        
        return nil
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
        Dropbox.authorizeFromController(UIApplication.sharedApplication(), controller: self, openURL: {(url: NSURL) -> Void in UIApplication.sharedApplication().openURL(url)})
    }
}

