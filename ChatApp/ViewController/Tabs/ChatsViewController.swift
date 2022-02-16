//
//  ChatsViewController.swift
//  ChatApp
//
//  Created by Vanderlei Thome on 15/02/22.
//

import UIKit
import FirebaseAuth
import FirebaseStorageUI
import FirebaseFirestore

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var auth: Auth!
    var firestore: Firestore!
    
    @IBOutlet weak var tableViewChats: UITableView!
    
    var chatsListener: ListenerRegistration!
    
    var chatsList: [Dictionary<String, Any>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        auth = Auth.auth()
        firestore = Firestore.firestore()
        
        tableViewChats.separatorStyle = .none
    }

    func addListenerGetChats() {
        if let currentUserId = auth.currentUser?.uid {
            chatsListener = firestore.collection("chats")
                .document(currentUserId)
                .collection("lastChat")
                .addSnapshotListener({ querySnap, error in
                    if error == nil {
                        self.chatsList.removeAll()
                        if let snapshot = querySnap {
                            for document in snapshot.documents {
                                let data = document.data()
                                self.chatsList.append(data)
                            }
                            self.tableViewChats.reloadData()
                        }
                    }
                })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellChat", for: indexPath) as! ChatsTableViewCell
        
        let index = indexPath.row
        
        let data = self.chatsList[index]
        let name = data["contactName"] as? String
        let lastChat = data["lastMessage"] as? String
        
        cell.chatName.text = name
        cell.chatLastMessage.text = lastChat
        
        if let urlImage = data["contactImagemUrl"] as? String {
            cell.chatImage.sd_setImage(with: URL(string: urlImage))
        } else {
            cell.chatImage.image = UIImage(named: "imagem-perfil")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewChats.deselectRow(at: indexPath, animated: true)
        
        let index = indexPath.row
        
        let chat = self.chatsList[index]
        
        if let id = chat["contactId"] as? String {
            if let name = chat["contactName"] as? String {
                if let url = chat["contactImagemUrl"] as? String {
                    let contact: Dictionary<String, Any> = [
                        "id": id,
                        "name": name,
                        "urlImage": url
                    ]
                    
                    self.performSegue(withIdentifier: "startChat2", sender: contact)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startChat2" {
            let targetView = segue.destination as! ChatMessageViewController
            targetView.contact = sender as? Dictionary
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addListenerGetChats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        chatsListener.remove()
    }

}
