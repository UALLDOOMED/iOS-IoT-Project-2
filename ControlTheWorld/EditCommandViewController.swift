//
//  EditCommandViewController.swift
//  ControlTheWorld
//
//  Created by Qiwei Wang on 10/11/19.
//  Copyright © 2019 Qiwei Wang. All rights reserved.
//

import UIKit
import Firebase
class EditCommandViewController: UIViewController {
    
    @IBOutlet weak var device: UILabel!
    @IBOutlet weak var voice: UITextField!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var btnConfirm: UIButton!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    weak var piResponseListener: ListenerRegistration?
    var command : Commands?
    override func viewDidLoad() {
        super.viewDidLoad()
        device.text = command?.device
        voice.text = command?.voice
        name.text = command?.name
        btnConfirm.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }
    @IBAction func confirm(_ sender: Any) {
        if voice.text != ""{
            updateCommand(device: device.text!,name: name.text!, voice: voice.text!)
        }
        else {
            self.displayMessage(title:"Voice Command field is empty", message: "")
        }
    }
    func updateCommand(device: String, name: String, voice: String) {
        delegate.db.collection("Commands").whereField("voice", isEqualTo: voice).getDocuments() {
            (querySnapshot, error) in
            if let error = error {
                print("Error getting documents \(error)")
            } else {
                if querySnapshot!.documents.count > 0 {
                    print("Voice command duplicate")
                    self.displayMessage(title:"Command deplicate", message: "")
                } else {
                    self.delegate.db.collection("Commands").whereField("device", isEqualTo: device).whereField("name", isEqualTo: name).getDocuments() {
                        (snapshot, err) in
                        if let err = err {
                            print("Error getting documents \(err)")
                        } else {
                            let documentId = snapshot!.documents[0].documentID
                            self.delegate.db.collection("Commands").document(documentId).updateData(["voice": voice]) { er in
                                if let er = er {
                                    print("Error updating document \(er)")
                                } else {
                                    print("updated")
                                    self.displayMessage(title:"Command updated", message: "")
                                }
                            }
                        }
                    }
                }
            }
        }

    }
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
