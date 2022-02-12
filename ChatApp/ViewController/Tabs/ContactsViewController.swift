//
//  ContactsViewController.swift
//  ChatApp
//
//  Created by Vanderlei Thome on 11/02/22.
//

import UIKit
import FirebaseStorageUI
import FirebaseAuth
import FirebaseFirestore

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    @IBOutlet weak var searchBarContacts: UISearchBar!
    
    var auth: Auth!
    var firestore: Firestore!
    
    var currentUserId: String!
    
    var contactsList: [Dictionary<String, Any>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        contactsTableView.separatorStyle = .none
        searchBarContacts.delegate = self
        
        auth = Auth.auth()
        firestore = Firestore.firestore()
        
        if let id = auth.currentUser?.uid {
            self.currentUserId = id
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let totalContacts = self.contactsList.count
        
        if totalContacts == 0 {
            return 1
        }
        
        return totalContacts
    }
    
    func getContacts() {
        self.contactsList.removeAll()
        
        firestore.collection("users")
            .document(currentUserId)
            .collection("contacts")
            .getDocuments { snapshotResult, error in
                if let snapshot = snapshotResult {
                    for document in snapshot.documents {
                        let data = document.data()
                        self.contactsList.append(data)
                    }
                    self.contactsTableView.reloadData()
                }
            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getContacts()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellContacts", for: indexPath) as! ContactsTableViewCell
        
        if self.contactsList.count == 0 {
            cell.contactName.text = "You have no contacts"
            cell.contactMail.text = ""
            return cell
        }
        
        let index = indexPath.row
        let contactData = self.contactsList[index]
        
        cell.contactName.text = contactData["name"] as? String
        cell.contactMail.text = contactData["email"] as? String
        
        if let photo = contactData["urlImage"] as? String {
            cell.contactImage.sd_setImage(with: URL(string: photo))
        } else {
            cell.contactImage.image = UIImage(named: "imagem-perfil")
        }
        
        return cell
    }

}
