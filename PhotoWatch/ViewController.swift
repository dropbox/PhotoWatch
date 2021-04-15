//
//  ViewController.swift
//  PhotoWatch
//
//  Created by Leah Culver on 5/11/15.
//  Copyright (c) 2015 DropboxClientsManager. All rights reserved.
//

import UIKit
import SwiftyDropbox

class ViewController: UIViewController, UIPageViewControllerDataSource {
    
    var filenames: Array<String>?
    

    override func viewDidAppear(_ animated: Bool) {
        self.filenames = []
        
        // Check if the user is logged in
        // If so, display photo view controller
        if let client = DropboxClientsManager.authorizedClient {
            
            // Display image background view w/logout button
            let backgroundViewController = self.storyboard?.instantiateViewController(withIdentifier: "BackgroundViewController")
            self.present(backgroundViewController!, animated: false, completion: nil)
            
            // List contents of app folder
            _ = client.files.listFolder(path: "").response { response, error in
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
                    let pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
                    pageViewController.dataSource = self
                    
                    // Display the first photo screen
                    if self.filenames != nil {
                        let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
                        photoViewController.filename = self.filenames!.first
                        pageViewController.setViewControllers([photoViewController], direction: .forward, animated: false, completion: nil)
                    }
                    
                    // Change the size of page view controller
                    pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 30);
                    
                    // Display the page view controller on top of background view controller
                    backgroundViewController!.addChild(pageViewController)
                    backgroundViewController!.view.addSubview(pageViewController.view)
                    pageViewController.didMove(toParent: self)
                    
                } else {
                    print("Error: \(error!)")
                }
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let filenames = self.filenames, let currentViewController = viewController as? PhotoViewController {
            var nextIndex = 0

            if let filename = currentViewController.filename, let index = filenames.firstIndex(of: filename) {
                if index < filenames.count - 1 {
                    nextIndex = index + 1
                }
            }
            guard nextIndex < filenames.count else { return nil }
            let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
            photoViewController.filename = filenames[nextIndex]
            
            return photoViewController
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let filenames = self.filenames, let currentViewController = viewController as? PhotoViewController {
            var nextIndex = self.filenames!.count - 1
            
            if let filename = currentViewController.filename, let index = filenames.firstIndex(of: filename) {
                if index > 0 {
                    nextIndex = index - 1
                }
            }
            guard nextIndex >= 0 else { return nil }

            let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
            photoViewController.filename = filenames[nextIndex]
            
            return photoViewController
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        // Number of pages is number of photos
        return self.filenames!.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }

    @IBAction func linkButtonPressed(_ sender: AnyObject) {
        // Present view to log in
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: self,
            loadingStatusDelegate: nil,
            openURL: {(url: URL) -> Void in UIApplication.shared.openURL(url)},
            scopeRequest: ScopeRequest(scopeType: .user,
                                       scopes: ["files.metadata.read", "files.content.read"],
                                       includeGrantedScopes: false))
    }
}

