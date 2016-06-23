//
//  HeaderView.swift
//  
//
//  Created by Jeanne Luning Prak on 6/22/16.
//
//

import UIKit
import ParseUI

class HeaderView: UITableViewCell {
    
    @IBOutlet weak var headerImage: PFImageView!
    @IBOutlet weak var userName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadUI(postedBy : PFUser, username : String) {
        self.userName.text = username
        let query = PFQuery(className:"Profile")
        query.whereKey("user", equalTo: postedBy)
        query.findObjectsInBackgroundWithBlock() {
            (post, error) -> Void in
            if error != nil {
                print("error")
            } else {
                if let post = post {
                    if(post.count == 0) {
                        self.headerImage.image = UIImage(named: "defaultProfile")
                    } else {
                        self.headerImage.file = post[0]["pic"] as? PFFile
                        self.headerImage.loadInBackground()
                    }
                }
            }
        }
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
