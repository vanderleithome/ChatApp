//
//  SignUpViewController.swift
//  ChatApp
//
//  Created by Vanderlei Thome on 04/02/22.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    var auth: Auth!
    
    @IBAction func createUser(_ sender: Any) {
        
        if let name = nameField.text {
            if let email = emailField.text {
                if let password = passwordField.text {
                    
                    auth.createUser(withEmail: email, password: password) { user, error in
                        if error == nil {
                            print("User created")
                        } else {
                            print("Error while creating user")
                        }
                    }
                    
                } else {
                    print("Choose your password")
                }
            } else {
                print("Type your email")
            }
        } else {
            print("Type your name")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        auth = Auth.auth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
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
