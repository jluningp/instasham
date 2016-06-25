//
//  ViewController.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/20/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var topBarAll: UILabel!
    @IBOutlet weak var topBar: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //To show with no posts
    @IBOutlet weak var noPosts: UILabel!
    @IBOutlet weak var noPostsInstasham: UILabel!
    @IBOutlet weak var noPostsLine: UILabel!
    
    var loadingMoreView:InfiniteScrollActivityView?
    
    var onlyFollowing = true
    var filteredPosts = [InstaPost]()
    
    var stopIncrementingInfiniteScroll = false
    var postArray = [InstaPost]()
    var queryLimitUnit = 20
    var queryLimit = 20
    var sendingFromPost = 0
    
    let CellIdentifier = "postCell", HeaderViewIdentifier = "headerCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.currentUser() != nil {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
            tableView.insertSubview(refreshControl, atIndex: 0)
            
            tableView.dataSource = self
            tableView.delegate = self
            
            tableView.estimatedRowHeight = 400.0
            tableView.rowHeight = UITableViewAutomaticDimension
            
            self.getPostsFromParse(nil)
            
            let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
            loadingMoreView = InfiniteScrollActivityView(frame: frame)
            loadingMoreView!.hidden = true
            tableView.addSubview(loadingMoreView!)
            
            var insets = tableView.contentInset;
            insets.bottom += InfiniteScrollActivityView.defaultHeight;
            tableView.contentInset = insets
        } else {
            logout()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if(self.navigationController != nil) {
            self.navigationController!.navigationBar.hidden = true
            topBarAll.hidden = false
            topBar.hidden = true
        } else {
            topBarAll.hidden = true
            topBar.hidden = false
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
        query.limit = queryLimit
        
        var postCount = 0
        
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (posts: [PFObject]?, error: NSError?) -> Void in
            if let posts = posts {
                postCount = posts.count
                self.postArray.removeAll()
                self.filteredPosts.removeAll()
                for i in 0..<postCount {
                    let nextPost = InstaPost(photo: posts[i]["media"] as! PFFile, caption: posts[i]["caption"] as! String, postedBy: posts[i]["author"] as! PFUser, timeStamp: posts[i].createdAt, id: posts[i].objectId!, likes: posts[i]["likesCount"] as! Int, userLikes: posts[i]["likes"] as! [PFUser], comments: posts[i]["comments"] as! [String], userComments: posts[i]["userComments"] as! [PFUser])
                    self.postArray.append(nextPost)
                    if(InstaPost.followingUser(nextPost.user)) {
                        print("following: \(nextPost.user.username!)")
                        self.filteredPosts.append(nextPost)
                    }
                }
            } else {
                print("Nothing was Sent from Server")
            }
            if(self.onlyFollowing) {
                postCount = self.filteredPosts.count
            }
            if(postCount >= self.queryLimit) {
                self.stopIncrementingInfiniteScroll = false
            }
            self.tableView.reloadData()
            if let refreshControl = refreshControl {
                refreshControl.endRefreshing()
            }
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.loadingMoreView!.stopAnimating()
        }
    }
    
    func logout() {
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
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                
                stopIncrementingInfiniteScroll = true
                
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                self.queryLimit += self.queryLimitUnit
                print(self.queryLimit)
                getPostsFromParse(nil)
            }
        }
    }
    
    
    func goToLoginScreen() {
        print("Should go to login screen")
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(self.onlyFollowing) {
            if(filteredPosts.count == 0) {
                tableView.hidden = true
                noPosts.hidden = false
                noPostsLine.hidden = false
                noPostsInstasham.hidden = false
            } else {
                tableView.hidden = false
                noPosts.hidden = true
                noPostsLine.hidden = true
                noPostsInstasham.hidden = true
            }
            return filteredPosts.count
        } else {
            return postArray.count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var posts = postArray
        if(self.onlyFollowing) {
            posts = filteredPosts
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as! PostCell
        
        cell.setPost(posts[indexPath.section])
        print(posts[indexPath.section])
        cell.loadUI()
        cell.tag = indexPath.section
        cell.numComments.tag = indexPath.section
        cell.makeComment.tag = indexPath.section
        return cell
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier(HeaderViewIdentifier)! as! HeaderView
        var posts = postArray
        if(self.onlyFollowing) {
            posts = filteredPosts
        }
        if(section < posts.count) {
            header.loadUI(posts[section].user, username: posts[section].postedBy)
            header.tag = section
            header.userName.tag = section
        }
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toDetails") {
            let nextView = segue.destinationViewController as! DetailsViewController
            nextView.post = postArray[sender!.tag]
        } else if(segue.identifier == "toComments") {
            let nextView = segue.destinationViewController as! CommentViewController
            nextView.post = postArray[sender!.tag]
        } else if(segue.identifier == "toOtherProfile") {
            let nextView = segue.destinationViewController as! OtherProfileViewController
            nextView.user = postArray[sender!.view.tag].user
        } else if(segue.identifier == "toOtherProfileButton") {
            let nextView = segue.destinationViewController as! OtherProfileViewController
            nextView.user = postArray[sender!.tag].user
        }
    }

}

