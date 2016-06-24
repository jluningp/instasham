//
//  NotifViewController.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/24/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class NotifViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var myNotifs = [Notification]()
    var queryLimit = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension

        
        getNotifsFromParse()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        getNotifsFromParse()
    }
    
    override func viewDidAppear(animated: Bool) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNotifsFromParse() {
        let query = PFQuery(className: "Notification")
        query.orderByDescending("createdAt")
        query.limit = queryLimit
        
        var postCount = 0
        
        query.findObjectsInBackgroundWithBlock { (posts: [PFObject]?, error: NSError?) -> Void in
            if let posts = posts {
                postCount = posts.count
                self.myNotifs.removeAll()
                for i in 0..<postCount {
                    let nextNotif = Notification(toNotify: posts[i]["toNotify"] as! PFUser, doneBy: posts[i]["doneBy"] as! PFUser, action: posts[i]["action"] as! String, doneTo: posts[i]["doneTo"] as! String)
                    self.myNotifs.append(nextNotif)
                }
            } else {
                print("Nothing was Sent from Server")
            }
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.tableView.reloadData()
        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myNotifs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notifCell") as! NotifCell
        cell.addNotif(myNotifs[indexPath.row])
        cell.loadUI()
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
