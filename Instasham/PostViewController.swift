//
//  PostViewController.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/20/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var captionEntry: UITextView!
    @IBOutlet weak var imageSelectView: UIView!
    @IBOutlet weak var imagePostView: UIView!
    
    
    var editedImage : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        if(previewImage.image == nil) {
            originalPicker()
        }
    }
    
    func originalPicker() {
        imageSelectView.hidden = false
        imagePostView.hidden = true
    }
    
    
    func imageFromLibrary(source : UIImagePickerControllerSourceType) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = source
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        previewImage.image = originalImage
        
        // Do something with the images (based on your use case)
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func makePost(sender: AnyObject) {
        //Other posting stuff
        let caption = captionEntry.text
        if let editedImage = editedImage {
            InstaPost.postUserImage(editedImage, withCaption: caption, withCompletion: nil)
        }
        previewImage.image = nil
        captionEntry.text = ""
        let tababarController = self.tabBarController! as UITabBarController
        tababarController.selectedIndex = 0
    }

    @IBAction func cameraRoll(sender: AnyObject) {
        imageSelectView.hidden = true
        imagePostView.hidden = false
        imageFromLibrary(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    
    @IBAction func takePhoto(sender: AnyObject) {
        imageSelectView.hidden = true
        imagePostView.hidden = false
        imageFromLibrary(UIImagePickerControllerSourceType.Camera)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
