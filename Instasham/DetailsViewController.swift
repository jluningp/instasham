//
//  DetailsViewController.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/21/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import ParseUI

class DetailsViewController: UIViewController {
    
    var post : InstaPost?
    @IBOutlet weak var photo: PFImageView!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var caption: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let post = post {
            self.photo.file = post.photo
            self.photo.loadInBackground()
            self.caption.text = post.caption
            caption.sizeToFit()
            caption.layoutIfNeeded()
            self.timestamp.text = post.timestamp
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
