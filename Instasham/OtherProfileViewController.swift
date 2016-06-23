//
//  OtherProfileViewController.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/23/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD
import ParseUI

class OtherProfileViewController: UIViewController, UICollectionViewDataSource {
    
    
    @IBOutlet weak var postNumber: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var postArray = [InstaPost]()
    var queryLimit = 20
    let queryLimitUnit = 20
    var stopIncrementingInfiniteScroll = false
    var loadingMoreView:InfiniteScrollActivityView?
    var user : PFUser?
    @IBOutlet weak var profilePic: PFImageView!
    @IBOutlet weak var topUsername: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        
        self.topUsername.text = user!.username!
        
        self.collectionView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
      
        let frame = CGRectMake(0, collectionView.contentSize.height, collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        collectionView.addSubview(loadingMoreView!)
        
        var insets = collectionView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        collectionView.contentInset = insets
        // Do any additional setup after loading the view.
        
        loadProfilePic()
        
        getPostsFromParse(refreshControl)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        self.queryLimit = self.queryLimitUnit
        self.getPostsFromParse(refreshControl)
    }
    
    func getPostsFromParse(refreshControl : UIRefreshControl?) {
        let query = PFQuery(className: "Post")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.whereKey("author", equalTo: PFUser.currentUser()!)
        query.limit = queryLimit
        
        var postCount = 0
        
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (posts: [PFObject]?, error: NSError?) -> Void in
            if let posts = posts {
                postCount = posts.count
                self.postArray.removeAll()
                for i in 0..<postCount {
                    self.postArray.append(InstaPost(photo: posts[i]["media"] as! PFFile, caption: posts[i]["caption"] as! String, postedBy: posts[i]["author"] as! PFUser, timeStamp: posts[i].createdAt, id: posts[i].objectId!, likes: posts[i]["likesCount"] as! Int, userLikes: posts[i]["likes"] as! [PFUser], comments: posts[i]["comments"] as! [String], userComments: posts[i]["userComments"] as! [PFUser]))
                }
                self.collectionView.reloadData()
                self.postNumber.text = "\(postCount)"
            } else {
                print("Nothing was Sent from Server")
            }
            if(postCount >= self.queryLimit) {
                self.stopIncrementingInfiniteScroll = false
            }
            self.collectionView.reloadData()
            if let refreshControl = refreshControl {
                refreshControl.endRefreshing()
            }
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.loadingMoreView!.stopAnimating()
        }
    }
    
    func circleProfile() {
        profilePic.layer.masksToBounds = false
        profilePic.layer.cornerRadius = profilePic.frame.size.height/2
        profilePic.clipsToBounds = true
    }
    
    func loadProfilePic() {
        circleProfile()
        self.profilePic.file = user!["profile"] as? PFFile
        self.profilePic.loadInBackground()
    }
    

    @IBAction func closeProfile(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("profileCell", forIndexPath: indexPath) as! ProfileCell
        cell.setPost(postArray[indexPath.row])
        cell.tag = indexPath.row
        cell.loadUI()
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toDetails") {
            let nextView = segue.destinationViewController as! DetailsViewController
            nextView.post = postArray[sender!.tag]
        }
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
