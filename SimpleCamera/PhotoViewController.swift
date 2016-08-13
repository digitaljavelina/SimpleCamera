//
//  PhotoViewController.swift
//  SimpleCamera
//
//  Created by Simon Ng on 25/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    @IBOutlet weak var imageView:UIImageView!

    var image:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
    }

    
    @IBAction func save(sender: AnyObject) {
        guard let imageToSave = image else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        dismissViewControllerAnimated(true, completion: nil)
    }

}
