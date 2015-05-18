//
//  PhotoInterfaceController.swift
//  PhotoWatch
//
//  Created by Leah Culver on 5/16/15.
//  Copyright (c) 2015 Dropbox. All rights reserved.
//

import WatchKit
import Foundation


class PhotoInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var image: WKInterfaceImage!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let data = context as? Dictionary<String, UIImage> {
            self.image.setImage(data["image"])
        }
    }
}