//
//  LoginViewController.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/20/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {


    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signIn(sender: AnyObject) {
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        PFUser.logInWithUsernameInBackground(username, password: password) {
            (user: PFUser?, error: NSError?) -> Void in
                if let error = error {
                    print("User login failed.")
                    print(error.localizedDescription)
                } else {
                    print("User logged in successfully")
                    self.goToMainScreen()
                    // display view controller that needs to shown after successful login
                }
            
        }
    }
    
    func goToMainScreen() {
        performSegueWithIdentifier("toMainScreen", sender: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        print("keyboard shown")
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardHeight = keyboardFrame!.size.height
        //buttonBottomConstraint.constant = keyboardHeight
        view.layoutIfNeeded()
    }
    
   
    @IBAction func signUp(sender: AnyObject) {
        let newUser = PFUser()
        
        // set user properties
        newUser.username = usernameField.text
        newUser.password = passwordField.text
        
        // call sign up function on the object
        newUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if let error = error {
                print(error.localizedDescription)
                if(error.code == 202) {
                    print("Preexisting User")
                }
            } else {
                print("User Registered successfully")
                self.goToMainScreen()
                // manually segue to logged in view
            }
        }
        
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
