//
//  HomePageViewController.swift
//  Telemed
//
//  Created by Macbook on 12/25/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit
import RealmSwift

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var taskTimeLabel: UILabel!
    @IBOutlet weak var taskInfoLabel: UILabel!
    @IBOutlet weak var appointmentTimeLabel: UILabel!
    @IBOutlet weak var appointmentInfoLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    
    
    let realm = try! Realm()
    var categories : Results<AllCategories>?
    var selectedCategory : Results<AllCategories>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        profileButton.layer.cornerRadius = 10.0
        
        let taskFormatter = DateFormatter()
        taskFormatter.amSymbol = "AM"
        taskFormatter.pmSymbol = "PM"
        taskFormatter.dateFormat = "hh:mm a"
        
        let appointmentFormatter = DateFormatter()
        appointmentFormatter.amSymbol = "AM"
        appointmentFormatter.pmSymbol = "PM"
        appointmentFormatter.dateFormat = "DD-MMM-YYYY hh:mm a"
        
        var taskCategory : Results<AllCategories>?
        var appointmentCategory : Results<AllCategories>?
        var taskItems : Results<AllItems>?
        var appointmentItems : Results<AllItems>?
        
        categories = realm.objects(AllCategories.self)
        if let allCategories = categories {
            taskCategory = allCategories.filter("name CONTAINS %@", "Tasks")
            appointmentCategory = allCategories.filter("name CONTAINS %@", "Appointments")
        }
        
        if taskCategory != nil {
            taskItems = taskCategory!.first?.allItems.filter("datetime >= %@", Date())
            taskItems = taskItems?.sorted(byKeyPath: "datetime", ascending: false)
            if let taskItem = taskItems?.first {
                taskTimeLabel.text = taskFormatter.string(from: taskItem.datetime)
                taskInfoLabel.text = taskItem.notes
            }
        }
        if appointmentCategory != nil {
            appointmentItems = appointmentCategory!.first?.allItems.filter("datetime >= %@", Date())
            appointmentItems = appointmentItems?.sorted(byKeyPath: "datetime", ascending: false)
            if let appointmentItem = appointmentItems?.first {
                appointmentTimeLabel.text = appointmentFormatter.string(from: appointmentItem.datetime)
                appointmentInfoLabel.text = appointmentItem.notes
            }
        }
        
        
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
    
    
}
