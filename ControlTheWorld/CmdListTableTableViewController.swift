//
//  CmdListTableTableViewController.swift
//  ControlTheWorld
//
//  Created by Qiwei Wang on 7/11/19.
//  Copyright © 2019 Qiwei Wang. All rights reserved.
//

import UIKit
import Firebase
class CmdListTableTableViewController: UITableViewController {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    weak var listener: ListenerRegistration?
    var commands: [Commands] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isTranslucent = true
        
//        self.navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.automatic
//        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func viewWillAppear(_ animated: Bool) {
        delegate.db.collection("Commands").getDocuments() {
        (querySnapshot, error) in
        if let error = error {
            print("Error getting documents: \(error)")
        } else {
            self.commands = []
            for document in querySnapshot!.documents {
                let command = Commands(device: (document.data()["device"] as! String), name: (document.data()["name"] as! String), remote: (document.data()["remote"] as! String), voice: (document.data()["voice"] as! String), command: (document.documentID ))
                self.commands.append(command)
            }
            self.tableView.reloadData()
    }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.commands.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CmdListTableViewCell
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.darkGray
        cell.selectedBackgroundView = bgColorView
        let command = self.commands[indexPath.row]
        cell.device.text = command.device
        cell.name.text = command.name
        cell.voice.text = command.voice
        return cell
    }
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editCommandSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! EditCommandViewController
                destinationController.command = commands[indexPath.row]
            }
        }
    }

}
