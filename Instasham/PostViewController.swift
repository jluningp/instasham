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
    @IBOutlet weak var filterNameLabel: UILabel!
    
    var editedImage : UIImage?
    var filteredImage : UIImage?
    var filterSelector = ["", "CIBumpDistortion", "CIGaussianBlur", "CIPixellate", "CISepiaTone", "CITwirlDistortion", "CIUnsharpMask", "CIVignette", "CIColorInvert"]
    var filterName = ["Normal", "Bump Distortion", "Gaussian Blur", "Pixellate", "Sepia Tone", "Twirl Distortion", "Unsharp Mask", "Vignette", "Color Invert"]
    var filterSelectorIndex = 0
    var keepImage = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        if(previewImage.image == nil) {
            originalPicker()
        }
        if(self.keepImage) {
            self.keepImage = false
        } else {
            originalPicker()
        }
    }
    
    func originalPicker() {
        previewImage.image = nil
        captionEntry.text = ""
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
        self.filteredImage = self.editedImage
        
        previewImage.image = filteredImage
        
        self.keepImage = true
        
        // Do something with the images (based on your use case)
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    @IBAction func previousFilter(sender: AnyObject) {
        filterSelectorIndex = (filterSelector.count + (filterSelectorIndex - 1)) % filterSelector.count
        print(filterSelectorIndex)
        filterImage()
        self.filterNameLabel.text = filterName[filterSelectorIndex]
    }
    
    @IBAction func nextFilter(sender: AnyObject) {
        filterSelectorIndex = (filterSelectorIndex + 1) % filterSelector.count
        print(filterSelectorIndex)
        filterImage()
        self.filterNameLabel.text = filterName[filterSelectorIndex]
    }
    
    
    func filterImage() {
        if(self.filterSelectorIndex == 0) {
            self.filteredImage = self.editedImage
            self.previewImage.image = self.filteredImage
        } else {
            let beginImage = CIImage(image: self.editedImage!)
            
            // 3
            let filter = CIFilter(name: filterSelector[self.filterSelectorIndex])
            filter!.setValue(beginImage, forKey: kCIInputImageKey)
            
            let inputKeys = filter!.inputKeys
            
            if inputKeys.contains(kCIInputIntensityKey) {
                filter!.setValue(0.5, forKey: kCIInputIntensityKey)
            }
            if inputKeys.contains(kCIInputRadiusKey) {
                if(filterSelectorIndex == 2) {
                    filter!.setValue(5, forKey: kCIInputRadiusKey)
                } else {
                    filter!.setValue(0.5 * 200, forKey: kCIInputRadiusKey)
                }
            }
            if inputKeys.contains(kCIInputScaleKey) {
                filter!.setValue(0.5 * 10, forKey: kCIInputScaleKey)
            }
            if inputKeys.contains(kCIInputCenterKey) {
                filter!.setValue(CIVector(x: self.editedImage!.size.width / 2, y: self.editedImage!.size.height / 2), forKey: kCIInputCenterKey)
            }
            
            // 4
            let newCGImage = convertCIImageToCGImage(filter!.outputImage!)
            let newImage = UIImage(CGImage: newCGImage)
            self.filteredImage = newImage
            self.previewImage.image = newImage
        }
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, fromRect: inputImage.extent)
    }
    
    
    @IBAction func makePost(sender: AnyObject) {
        //Other posting stuff
        let caption = captionEntry.text
        if let filteredImage = filteredImage {
            InstaPost.postUserImage(filteredImage, withCaption: caption, withCompletion: nil)
        }
        previewImage.image = nil
        captionEntry.text = ""
        let tababarController = self.tabBarController! as UITabBarController
        tababarController.selectedIndex = 0
        keepImage = false
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
