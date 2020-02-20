//
//  ChooseCommandTableViewController.swift
//  ControlTheWorld
//
//  Created by Kang Meng on 10/11/19.
//  Copyright © 2019 Qiwei Wang. All rights reserved.
//

import UIKit

class ChooseCommandTableViewController: UITableViewController {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var commands: [Commands] = []
    
    weak var chooseCommandDelegate: ChooseCommandDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get documents from firebase
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.commands.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chooseCommandCell", for: indexPath) as! ChooseTaskTableViewCell
        let command = self.commands[indexPath.row]
        cell.deviceLabel.text = command.device
        cell.commandLabel.text = command.name

        // Configure the cell...

        return cell
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chooseCommandDelegate!.chooseCommand(command: commands[indexPath.row])
        navigationController?.popViewController(animated: true)
        return
    }

}
