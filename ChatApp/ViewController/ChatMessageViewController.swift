//
//  ChatMessageViewController.swift
//  ChatApp
//
//  Created by Vanderlei Thome on 14/02/22.
//

import UIKit

class ChatMessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableViewMessages: UITableView!
    
    @IBOutlet weak var attachButton: UIButton!
    
    @IBOutlet weak var messageField: UITextField!
    
    var messagesList: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableViewMessages.backgroundView = UIImageView(image: UIImage(named: "bg"))
        tableViewMessages.separatorStyle = .none
        
        messagesList = ["Olá", "Tudo bem?", "Tudo e tu?", "Tudo certo!", "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk"]
    }
    
    @IBAction func sendMessage(_ sender: Any) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
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
        
        let message = self.messagesList[index]
        
        if index % 2 == 0 {
            cellRight.messageRightLabel.text = message
            return cellRight
        } else {
            cellLeft.messageLeftLabel.text = message
            return cellLeft
        }
    }

}
