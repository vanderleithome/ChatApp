//
//  ChatMessageViewController.swift
//  ChatApp
//
//  Created by Vanderlei Thome on 14/02/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatMessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableViewMessages: UITableView!
    
    @IBOutlet weak var attachButton: UIButton!
    
    @IBOutlet weak var messageField: UITextField!
    
    var messagesList: [Dictionary<String, Any>]! = []
    
    var auth: Auth!
    
    var firestore: Firestore!
    
    var currentUserId: String!
    
    var contact: Dictionary<String, Any>!
    
    var messagesListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        auth = Auth.auth()
        firestore = Firestore.firestore()
        
        if let id = auth.currentUser?.uid {
            self.currentUserId = id
        }
        
        if let contactName = contact["name"] {
            self.navigationItem.title = contactName as? String
        }
        
        tableViewMessages.backgroundView = UIImageView(image: UIImage(named: "bg"))
        tableViewMessages.separatorStyle = .none
        
        //messagesList = ["Olá", "Tudo bem?", "Tudo e tu?", "Tudo certo!", "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk"]
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if let textTyped = messageField.text {
            if !textTyped.isEmpty {
                if let contactUserId = contact["id"] as? String {
                    
                    let message = [
                        "userId": self.currentUserId!,
                        "text": textTyped,
                        "date": FieldValue.serverTimestamp()
                    ] as [String : Any]
                    
                    saveMessage(userId: self.currentUserId, contactId: contactUserId, message: message as Dictionary<String, Any>)
                    
                    saveMessage(userId: contactUserId, contactId: self.currentUserId, message: message as Dictionary<String, Any>)
                }
            }
        }
    }
    
    func saveMessage(userId: String, contactId: String, message: Dictionary<String, Any>) {
        firestore.collection("messages")
            .document(userId)
            .collection(contactId)
            .addDocument(data: message)
        
        self.messageField.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        addListenerGetMessages()
    }
    
    func addListenerGetMessages() {
        if let contactId = contact["id"] as? String {
            messagesListener = firestore.collection("messages")
                .document(currentUserId)
                .collection(contactId)
                .order(by: "date", descending: false)
                .addSnapshotListener { querySnapshot, error in
                    self.messagesList.removeAll()
                    if let snapshot = querySnapshot {
                        for document in snapshot.documents {
                            let data = document.data()
                            self.messagesList.append(data)
                        }
                        self.tableViewMessages.reloadData()
                    }
                }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        messagesListener.remove()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellRight = tableView.dequeueReusableCell(withIdentifier: "cellMessagesRight", for: indexPath) as! MessagesTableViewCell
        
        let cellLeft = tableView.dequeueReusableCell(withIdentifier: "cellMessagesLeft", for: indexPath) as! MessagesTableViewCell
        
        let index = indexPath.row
        
        let data = self.messagesList[index]
        let text = data["text"] as? String
        let userId = data["userId"] as? String
        
        if currentUserId == userId {
            cellRight.messageRightLabel.text = text
            return cellRight
        } else {
            cellLeft.messageLeftLabel.text = text
            return cellLeft
        }
    }

}
