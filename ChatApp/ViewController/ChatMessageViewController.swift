//
//  ChatMessageViewController.swift
//  ChatApp
//
//  Created by Vanderlei Thome on 14/02/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ChatMessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableViewMessages: UITableView!
    
    @IBOutlet weak var attachButton: UIButton!
    
    @IBOutlet weak var messageField: UITextField!
    
    var messagesList: [Dictionary<String, Any>]! = []
    
    var auth: Auth!
    
    var firestore: Firestore!
    
    var storage: Storage!
    
    var imagePicker = UIImagePickerController()
    
    var currentUserId: String!
    
    var currentUserName: String!
    
    var currentUserImageUrl: String!
    
    var contactName: String!
    
    var contactImageUrl: String!
    
    var contact: Dictionary<String, Any>!
    
    var messagesListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        auth = Auth.auth()
        firestore = Firestore.firestore()
        storage = Storage.storage()
        
        imagePicker.delegate = self
        
        if let id = auth.currentUser?.uid {
            self.currentUserId = id
            getUserData()
        }
        
        if let contactName = contact["name"] {
            self.contactName = contactName as? String
            self.navigationItem.title = contactName as? String
        }
        
        if let url = contact["urlImage"] as? String {
            self.contactImageUrl = url
        }
        
        tableViewMessages.backgroundView = UIImageView(image: UIImage(named: "bg"))
        tableViewMessages.separatorStyle = .none
        
        //messagesList = ["Olá", "Tudo bem?", "Tudo e tu?", "Tudo certo!", "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk"]
    }
    
    func getUserData() {
        let user = self.firestore.collection("users").document(currentUserId)
        
        user.getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.currentUserName = data["name"] as? String
                self.currentUserImageUrl = data["urlImage"] as? String
            }
        }
    }
    
    @IBAction func sendImage(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let imageRecovered = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        let images = storage.reference().child("images")
        
        if let imageUpload = imageRecovered.jpegData(compressionQuality: 0.3) {
            
            let uId = UUID().uuidString
            let imageName = "\(uId).jpg"
            let imageMessageRef = images.child("messages").child(imageName)
            
            imageMessageRef.putData(imageUpload, metadata: nil) { metadata, error in
                if error == nil {
                    
                    imageMessageRef.downloadURL { url, error in
                        if let imageUrl = url?.absoluteString {
                            
                            if let contactUserId = self.contact["id"] as? String {
                                
                                let message = [
                                    "userId": self.currentUserId!,
                                    "imageUrl": imageUrl,
                                    "date": FieldValue.serverTimestamp()
                                ] as [String : Any]
                                
                                self.saveMessage(userId: self.currentUserId, contactId: contactUserId, message: message as Dictionary<String, Any>)
                                
                                self.saveMessage(userId: contactUserId, contactId: self.currentUserId, message: message as Dictionary<String, Any>)
                                
                                var chat: Dictionary<String, Any> = [
                                    "lastMessage": "Image..."
                                ]
                                
                                chat["userId"] = self.currentUserId!
                                chat["contactId"] = contactUserId
                                chat["contactName"] = self.contactName!
                                chat["contactImagemUrl"] = self.contactImageUrl!
                                self.saveChat(userId: self.currentUserId, contactId: contactUserId, chat: chat)
                                
                                chat["userId"] = contactUserId
                                chat["contactId"] = self.currentUserId!
                                chat["contactName"] = self.currentUserName
                                chat["contactImagemUrl"] = self.currentUserImageUrl
                                self.saveChat(userId: contactUserId, contactId: self.currentUserId, chat: chat)
                            }
                            
                        }
                    }
                    
                } else {
                    print("Error on uploading image")
                }
            }
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
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
                    
                    var chat: Dictionary<String, Any> = [
                        "lastMessage": textTyped
                    ]
                    
                    chat["userId"] = self.currentUserId!
                    chat["contactId"] = contactUserId
                    chat["contactName"] = self.contactName!
                    chat["contactImagemUrl"] = self.contactImageUrl!
                    self.saveChat(userId: self.currentUserId, contactId: contactUserId, chat: chat)
                    
                    chat["userId"] = contactUserId
                    chat["contactId"] = self.currentUserId!
                    chat["contactName"] = self.currentUserName
                    chat["contactImagemUrl"] = self.currentUserImageUrl
                    self.saveChat(userId: contactUserId, contactId: self.currentUserId, chat: chat)
                    
                }
            }
        }
    }
    
    func saveChat(userId: String, contactId: String, chat: Dictionary<String, Any>) {
        firestore.collection("chats")
            .document(userId)
            .collection("lastChat")
            .document(contactId)
            .setData(chat)
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
        
        let cellImageRight = tableView.dequeueReusableCell(withIdentifier: "cellImageRight", for: indexPath) as! MessagesTableViewCell
        
        let cellImageLeft = tableView.dequeueReusableCell(withIdentifier: "cellImageLeft", for: indexPath) as! MessagesTableViewCell
        
        let index = indexPath.row
        
        let data = self.messagesList[index]
        let text = data["text"] as? String
        let userId = data["userId"] as? String
        let imageUrl = data["imageUrl"] as? String
        
        if currentUserId == userId {
            
            if imageUrl != nil {
                cellImageRight.imageRight.sd_setImage(with: URL(string: imageUrl!))
                return cellImageRight
            }
            
            cellRight.messageRightLabel.text = text
            return cellRight
            
        } else {
            
            if imageUrl != nil {
                cellImageLeft.imageLeft.sd_setImage(with: URL(string: imageUrl!))
                return cellImageLeft
            }
            
            cellLeft.messageLeftLabel.text = text
            return cellLeft
            
        }
    }

}
