//
//  SettingsViewController.swift
//  ChatApp
//
//  Created by Vanderlei Thome on 05/02/22.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseStorageUI

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var auth: Auth!
    var storage: Storage!
    var firestore: Firestore!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var imageProfile: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    var userID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()
        
        if let id = auth.currentUser?.uid {
            self.userID = id
        }
        
        getUserData()
        
        imagePicker.delegate = self
    }
    
    func getUserData() {
        let userRef = self.firestore.collection("users").document(userID)
        
        userRef.getDocument { snapshot, error in
            if let data = snapshot?.data() {
                let userName = data["name"] as? String
                let userMail = data["email"] as? String
                
                self.nameLabel.text = userName
                self.emailLabel.text = userMail
                
                if let imageURL = data["urlImage"] as? String {
                    self.imageProfile.sd_setImage(with: URL(string: imageURL))
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let imageReturned = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        self.imageProfile.image = imageReturned
        
        let images = storage.reference().child("imagens")
        
        if let imageUpload = imageReturned.jpegData(compressionQuality: 0.3) {
            if let userLoggedIn = auth.currentUser {
                let userID = userLoggedIn.uid
                
                let imageName = "\(userID).jpg"
                
                let imageProfileRef = images.child("profile").child(imageName)
                imageProfileRef.putData(imageUpload, metadata: nil) { metadata, error in
                        if error == nil {
                            imageProfileRef.downloadURL { url, error in
                                if let urlImage = url?.absoluteString {
                                    self.firestore
                                        .collection("users")
                                        .document(userID)
                                        .updateData(["urlImage": urlImage])
                                }
                            }
                            print("Image uploaded successfull")
                        } else {
                            print("Error on uploading image: \(error)")
                        }
                    }
            }
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeImage(_ sender: Any) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try auth.signOut()
        } catch {
            print("Error on logout")
        }
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
