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
    
    var handler: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        auth = Auth.auth()
        
        handler = auth.addStateDidChangeListener { autentitation, user in
            if user != nil {
                self.performSegue(withIdentifier: "segueAutomaticLogin", sender: nil)
            }
        }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        //auth.removeStateDidChangeListener(handler)
    }
    
    @IBAction func unwindToLogin(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
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
