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
        if searchText == "" {
            getContacts()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let textTyped = searchBar.text
        
        if textTyped != "" {
            searchContacts(pText: textTyped!)
        }
    }
    
    func searchContacts(pText: String) {
        
        let filterList: [Dictionary<String, Any>] = self.contactsList
        
        self.contactsList.removeAll()
        
        for item in filterList {
            if let name = item["name"] as? String {
                if name.lowercased().contains(pText.lowercased()) {
                    self.contactsList.append(item)
                }
            }
        }
        
        self.contactsTableView.reloadData()
        
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
        
        cell.contactImage.isHidden = false
        if self.contactsList.count == 0 {
            cell.contactName.text = "You have no contacts"
            cell.contactMail.text = ""
            cell.contactImage.isHidden = true
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.contactsTableView.deselectRow(at: indexPath, animated: true)
        
        let index = indexPath.row
        
        let contact = self.contactsList[index]
        
        self.performSegue(withIdentifier: "startChat", sender: contact)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startChat" {
            let targetView = segue.destination as! ChatMessageViewController
            targetView.contact = sender as? Dictionary
        }
    }

}
