//
//  NewContactViewController.swift
//  ChatApp
//
//  Created by Vanderlei Thome on 12/02/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NewContactViewController: UIViewController {

    @IBOutlet weak var contactEmail: UITextField!
    
    @IBOutlet weak var errorMessage: UILabel!
    
    var currentUserId: String!
    var currentUserEmail: String!
    
    var auth: Auth!
    var firestore: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        auth = Auth.auth()
        firestore = Firestore.firestore()
        
        if let currentUser = auth.currentUser {
            self.currentUserId = currentUser.uid
            self.currentUserEmail = currentUser.email
        }
    }
    
    @IBAction func addContact(_ sender: Any) {
        
        self.errorMessage.isHidden = true
        
        if let typedEmail = contactEmail.text {
            if typedEmail == self.currentUserEmail {
                self.errorMessage.isHidden = false
                self.errorMessage.text = "Invalid email account"
                return
            }
            
            firestore.collection("users")
                .whereField("email", isEqualTo: typedEmail)
                .getDocuments { snapshotResult, error in
                    if let totalItens = snapshotResult?.count {
                        if totalItens == 0 {
                            self.errorMessage.text = "User not found"
                            self.errorMessage.isHidden = false
                            return
                        }
                    }
                    
                    if let snapshot = snapshotResult {
                        for document in snapshot.documents {
                            let data = document.data()
                            self.saveContact(data: data)
                        }
                    }
                }
        }
    }
    
    func saveContact(data: Dictionary<String, Any>) {
        
        if let userIdContact = data["id"] {
            firestore.collection("users")
                .document(currentUserId)
                .collection("contacts")
                .document(String(describing: userIdContact))
                .setData(data) { error in
                    if error == nil {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
        }
    }
}
