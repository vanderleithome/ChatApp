//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Vanderlei Thome on 04/02/22.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    var auth: Auth!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        auth = Auth.auth()
    }
    
    @IBAction func loginUser(_ sender: Any) {
        
        if let email = emailField.text {
            if let password = passwordField.text {
                
                auth.signIn(withEmail: email, password: password) { user, error in
                    if error == nil {
                        if let userLoggedIn = user {    
                            print("User logged in successfull - \(String(describing: userLoggedIn.user.email))")
                        }
                    } else {
                        print("Error while logging in")
                    }
                }
                
            } else {
                print("Type your password")
            }
        } else {
            print("Type your email")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
