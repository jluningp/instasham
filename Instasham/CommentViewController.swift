//
//  CommentViewController.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/22/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import Parse

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var post : InstaPost?
    @IBOutlet weak var commentEntry: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    @IBAction func postComment(sender: AnyObject) {
        let comment = commentEntry.text ?? ""
        post!.updateComments(Comment(user: PFUser.currentUser()!, comment: comment))
        tableView.reloadData()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post!.userComments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! CommentCell
        cell.setComment(Comment(user: post!.userComments[indexPath.row], comment: post!.comments[indexPath.row]))
        cell.loadUI()
        cell.tag = indexPath.row
        return cell
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
