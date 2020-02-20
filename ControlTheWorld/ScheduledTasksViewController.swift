//
//  ScheduledTasksViewController.swift
//  ControlTheWorld
//
//  Created by Kang Meng on 10/11/19.
//  Copyright © 2019 Qiwei Wang. All rights reserved.
//

import UIKit
import Firebase

class ScheduledTasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChooseCommandDelegate {
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chooseCommandButton: UIButton!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var scheduledTasks: [ScheduledTasks] = []
    var chosenCommand: Commands?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timePicker.setValue(UIColor.white, forKey: "textColor")
        self.timePicker.setValue(false, forKey: "highlightsToday")
        self.timePicker.minimumDate = Date()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        // Listen on the changes of ScheduledTasks collection to update the table content
        delegate.db.collection("ScheduledTasks").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents \(error!)")
                return
            }
            self.delegate.db.collection("ScheduledTasks").order(by: "timestamp", descending: false).getDocuments() {
                (querySnapshot2, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.scheduledTasks = []
                    for document in querySnapshot2!.documents {
                        let scheduledTask = ScheduledTasks(id: document.documentID ,command: document.data()["command"] as! String, device: document.data()["device"] as! String, status: document.data()["status"] as! String, timestamp: (document.data()["timestamp"] as! Timestamp).dateValue())
                        if scheduledTask.status == "queried" {
                            self.scheduledTasks.append(scheduledTask)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.scheduledTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commandCell", for: indexPath) as! ScheduledTasksTableViewCell
        let scheduledTask = self.scheduledTasks[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        dateFormatter.timeZone = .current
        cell.commandLabel.text = scheduledTask.device + " " + scheduledTask.command
        cell.timeLabel.text = dateFormatter.string(from: scheduledTask.timestamp)
        return cell
    }
    
    /// Add a new scheduled task to firebase for execution
    ///
    /// - Parameter sender
    @IBAction func clickSave(_ sender: Any) {
        delegate.db.collection("ScheduledTasks").addDocument(data: [
            "command": self.chosenCommand?.remote,
            "device": self.chosenCommand?.device,
            "status": "queried",
            "timestamp": self.timePicker.date
            ])
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "chooseCommandSegue" {
            let destination = segue.destination as! ChooseCommandTableViewController
            destination.chooseCommandDelegate = self
        }
    }
    
    func chooseCommand(command: Commands) {
        self.chosenCommand = command
        chooseCommandButton.setTitle(command.name, for: .normal)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delegate.db.collection("ScheduledTasks").document(scheduledTasks[indexPath.row].id).delete()
        }
    }
}
