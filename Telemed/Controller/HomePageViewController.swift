//
//  HomePageViewController.swift
//  Telemed
//
//  Created by Macbook on 12/25/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit
import RealmSwift

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    let tasks = [["9:00 pm", "Task A"], ["12:00 pm", "Task B"], ["9:00 pm", "Task A"], ["12:00 pm", "Task B"]]
    let appointments = [["12 Dec 2018", "9:00 pm Dr. Hello World"], ["12 Dec 2018", "9:00 pm Dr. Hello World"], ["12 Dec 2018", "9:00 pm Dr. Hello World"]]

    
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var appointmentTableView: UITableView!
    
    let realm = try! Realm()
    var categories : Results<AllCategories>?
    var selectedCategory : Results<AllCategories>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        taskTableView.delegate = self
        taskTableView.dataSource = self
        
        appointmentTableView.delegate = self
        appointmentTableView.dataSource = self
        
        taskTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "taskCell")
        
        appointmentTableView.register(UINib(nibName: "AppointmentTableViewCell", bundle: nil), forCellReuseIdentifier: "appointmentCell")
        
        configureTable(taskTableView)
        configureTable(appointmentTableView)
        
        categories = realm.objects(AllCategories.self)
        
        if let allCategories = categories {
            
            if allCategories.count != 2 {
                do {
                    try realm.write {
                        
                        for allCategory in allCategories {
                            realm.delete(allCategory)
                        }
                        
                        let newTask = AllCategories()
                        newTask.name = "Tasks"
                        newTask.needUpdate = true
                        let newAppointments = AllCategories()
                        newAppointments.name = "Appointments"
                        newTask.needUpdate = true
                        realm.add(newTask)
                        realm.add(newAppointments)
                    }
                } catch {
                    print("Error setting up categories: \(error)")
                }
            }
        }
    }
    

    @IBAction func profileButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "goToProfile", sender: self)
        
    }
    
    @IBAction func tasksButtonPressed(_ sender: Any) {
        
        if let allCategories = categories {
            selectedCategory = allCategories.filter("name CONTAINS %@", "Tasks")
            performSegue(withIdentifier: "goToAll", sender: self)
        }
        
        
    }
    
    @IBAction func appointmentsButtonPressed(_ sender: Any) {
        
        if let allCategories = categories {
            selectedCategory = allCategories.filter("name CONTAINS %@", "Appointments")
            performSegue(withIdentifier: "goToAll", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "goToAll" {
            let destinationVC = segue.destination as! AllViewController
            if let destinationCategory = selectedCategory?[0] {
                destinationVC.selectedCategory = destinationCategory
                destinationVC.titleName = destinationCategory.name
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == taskTableView {
            return tasks.count
        }
        else if tableView == appointmentTableView {
            return appointments.count
        }
        
        return 3
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == taskTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! HomeTableViewCell
            cell.taskTime.text = tasks[indexPath.row][0]
            cell.taskInfo.text = tasks[indexPath.row][1]
            cell.selectionStyle = .none
            return cell
            
        }
        else if tableView == appointmentTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentCell", for: indexPath) as! AppointmentTableViewCell
            cell.date.text = appointments[indexPath.row][0]
            cell.info.text = appointments[indexPath.row][1]
            cell.selectionStyle = .none
            return cell
            
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "none", for: indexPath)
        
    }
    
    func configureTable(_ table : UITableView) {
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120.0
    }
    
}
