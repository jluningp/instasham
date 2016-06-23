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
    
    func circleHeader() {
        headerImage.layer.masksToBounds = false
        headerImage.layer.cornerRadius = headerImage.frame.size.height/2
        headerImage.clipsToBounds = true
    }
    
    func loadUI(postedBy : PFUser, username : String) {
        circleHeader()
        self.userName.text = username
        if let profile = postedBy["profile"] {
            self.headerImage.file = profile as? PFFile
            self.headerImage.loadInBackground()
        }
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
