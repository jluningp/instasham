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

   
    @IBOutlet weak var tableView: UITableView!
    var loadingMoreView:InfiniteScrollActivityView?
    
    var stopIncrementingInfiniteScroll = false
    var postArray = [InstaPost]()
    var queryLimitUnit = 20
    var queryLimit = 20
    var sendingFromPost = 0
    
    let CellIdentifier = "postCell", HeaderViewIdentifier = "headerCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //tableView.registerClass(PostCell.self, forCellReuseIdentifier: CellIdentifier)
        //tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderViewIdentifier)
        
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
                for i in 0..<postCount {
                    self.postArray.append(InstaPost(photo: posts[i]["media"] as! PFFile, caption: posts[i]["caption"] as! String, postedBy: posts[i]["author"] as! PFUser, timeStamp: posts[i].createdAt, id: posts[i].objectId!, likes: posts[i]["likesCount"] as! Int, userLikes: posts[i]["likes"] as! [PFUser], comments: posts[i]["comments"] as! [String], userComments: posts[i]["userComments"] as! [PFUser]))
                }
            } else {
                print("Nothing was Sent from Server")
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
        return postArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as! PostCell
        cell.setPost(postArray[indexPath.section])
        cell.loadUI()
        cell.tag = indexPath.section
        cell.numComments.tag = indexPath.section
        cell.makeComment.tag = indexPath.section
        return cell
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier(HeaderViewIdentifier)! as! HeaderView
        if(section < postArray.count) {
            header.loadUI(postArray[section].user, username: postArray[section].postedBy)
            header.tag = section
        }
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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
        }
    }

}

