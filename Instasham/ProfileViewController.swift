//
//  ProfileViewController.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/20/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MBProgressHUD

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource {
    

    @IBOutlet weak var profilePic: PFImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var username: UILabel!
    var loadingMoreView:InfiniteScrollActivityView?
    
    var stopIncrementingInfiniteScroll = false
    var postArray = [InstaPost]()
    var queryLimitUnit = 3
    var queryLimit = 3
    var sendingFromPost = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        collectionView.dataSource = self
        self.getPostsFromParse(nil)
        
        self.username.text = PFUser.currentUser()!.username
        username.sizeToFit()
        
        let frame = CGRectMake(0, collectionView.contentSize.height, collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        collectionView.addSubview(loadingMoreView!)
        
        var insets = collectionView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        collectionView.contentInset = insets
        
        loadProfilePic()
    }
    
    func loadProfilePic() {
        let query = PFQuery(className:"Profile")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock() {
            (post, error) -> Void in
            if error != nil {
                print("error")
            } else {
                if let post = post {
                    if(post.count != 0) {
                        self.profilePic.file = post[0]["pic"] as? PFFile
                        self.profilePic.loadInBackground()
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.queryLimit = self.queryLimitUnit
        self.getPostsFromParse(nil)
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
    

    @IBAction func logOut(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            if let error = error {
                print("Failed to log out")
            } else {
                print("Logout Successful")
                self.goToLoginScreen()
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!stopIncrementingInfiniteScroll) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = collectionView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - collectionView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && collectionView.dragging) {
                
                stopIncrementingInfiniteScroll = true
                
                let frame = CGRectMake(0, collectionView.contentSize.height, collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                self.queryLimit += self.queryLimitUnit
                print(self.queryLimit)
                getPostsFromParse(nil)
            }
        }
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
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        InstaPost.updateProfilePic(editedImage)
        
        profilePic.image = editedImage

        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func newProfilePic(sender: AnyObject) {
        imageFromLibrary(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    
    
    func goToLoginScreen() {
            //reload application data (renew root view )
        UIApplication.sharedApplication().keyWindow?.rootViewController = storyboard!.instantiateViewControllerWithIdentifier("loginScreen")
        print("Should go to login screen")
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
    
}