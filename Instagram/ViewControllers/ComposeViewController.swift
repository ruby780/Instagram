//
//  ComposeViewController.swift
//  Instagram
//
//  Created by Ruben A Gonzalez on 2/26/18.
//  Copyright © 2018 Ruben A Gonzalez. All rights reserved.
//

import UIKit
import Parse

class ComposeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var captionField: UITextView!
    @IBOutlet weak var postImageView: UIImageView!
    let vc = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vc.delegate = self
        vc.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
        }
        postImageView.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.
    }

    @IBAction func selectImage(_ sender: Any) {
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func postImage(_ sender: Any) {
        let caption = captionField.text ?? ""
        let image = resize(image: postImageView.image!, newSize: CGSize(width: 300, height: 300))
        
        Post.postUserImage(image: image, withCaption: caption) { (success: Bool, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Yay! Posted a photo!")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        //let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        postImageView.image = originalImage
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func cancelShare(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        resizeImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}


