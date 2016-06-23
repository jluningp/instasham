//
//  ProfileCell.swift
//  
//
//  Created by Jeanne Luning Prak on 6/22/16.
//
//

import UIKit
import ParseUI

class ProfileCell: UICollectionViewCell {
    
    @IBOutlet weak var image: PFImageView!
    var post : InstaPost?
    
    func setPost(post : InstaPost) {
        self.post = post
    }
    
    func loadUI() {
        self.image.file = post!.photo
        self.image.loadInBackground()
    }
    
}
