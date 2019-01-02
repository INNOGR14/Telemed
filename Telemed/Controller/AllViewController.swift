//
//  AllViewController.swift
//  Telemed
//
//  Created by Macbook on 1/1/19.
//  Copyright © 2019 drsocgr14. All rights reserved.
//

import UIKit
import RealmSwift

class AllViewController: UIViewController {
    
    let tasks = [[1, "Task A"], [2, "Task B"], [3, "Task A"], [4, "Task B"]]
    let appointments = [[1, "Dr. Hello World"], [2, "Dr. Hello World"], [3, "Dr. Hello World"]]
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var allTable: UITableView!
    
    
    let realm = try! Realm()
    let formatter = DateFormatter()
    let dayFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var titleName : String?
    var tableDict : [[String : Any]]?
    
    var items : Results<AllItems>?
    var selectedCategory : AllCategories? {
        didSet {
            items = selectedCategory?.allItems.sorted(byKeyPath: "datetime", ascending: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        allTable.register(UINib(nibName: "AppointmentTableViewCell", bundle: nil), forCellReuseIdentifier: "allCell")
        allTable.delegate = self
        allTable.dataSource = self
        
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        timeFormatter.amSymbol = "PM"
        timeFormatter.pmSymbol = "PM"
        titleLabel.text = titleName ?? "Error"
        
        
        if let currentCategory = selectedCategory {
            
            if currentCategory.name == "Tasks" {
                formatter.dateFormat = "dd MMM hh:mm a"
                dayFormatter.dateFormat = "dd MMM"
                timeFormatter.dateFormat = "hh:mm a"
                
                for item in currentCategory.allItems {
                    
                    let time = Calendar.current.dateComponents([.hour, .minute, .second], from: item.datetime)
                    let formattedTime = item.datetime + TimeInterval(-(time.hour! * 3600 + time.minute! * 60 + time.second!))
                    if tableDict == nil {
                        tableDict = [["date" : formattedTime, "count" : 1]]
                    }
                    else {
                        var appendable = true
                        
                        for (index, element) in tableDict!.enumerated() {
                            if element["date"] as! Date == formattedTime {
                                appendable = false
                                tableDict![index]["count"] = tableDict![index]["count"] as! Int + 1
                            }
                        }
                        if appendable {
                            tableDict!.append(["date" : formattedTime, "count" : 1])
                        }
                    }
                    if tableDict != nil {
                        tableDict = tableDict!.sorted(by: { $0["date"] as! Date > $1["date"] as! Date})
                    }
                }
            }
            else {
                formatter.dateFormat = "dd MMM yyyy hh:mm a"
                dayFormatter.dateFormat = "MMM YYYY"
                timeFormatter.dateFormat = "dd hh:mm a"
                
                for item in currentCategory.allItems {
                    
                    let time = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: item.datetime)
                    let formattedTime = item.datetime + TimeInterval(-(time.day! * 86400 + time.hour! * 3600 + time.minute! * 60 + time.second!))
                    if tableDict == nil {
                        tableDict = [["date" : formattedTime, "count" : 1]]
                    }
                    else {
                        var appendable = true
                        
                        for (index, element) in tableDict!.enumerated() {
                            if element["date"] as! Date == formattedTime {
                                appendable = false
                                tableDict![index]["count"] = tableDict![index]["count"] as! Int + 1
                            }
                        }
                        if appendable {
                            tableDict!.append(["date" : formattedTime, "count" : 1])
                        }
                    }
                    if tableDict != nil {
                        tableDict = tableDict!.sorted(by: { $0["date"] as! Date > $1["date"] as! Date})
                    }
                }
            }
        }
        
        do {
            try realm.write {
                if selectedCategory?.name == "Appointments" {
                    for appointment in appointments {
                        let newAppointment = AllItems()
                        newAppointment.datetime = Date(timeIntervalSinceNow: TimeInterval(3600 * (appointment[0] as! Int)))
                        newAppointment.notes = appointment[1] as! String
                        newAppointment.uuid = UUID().uuidString
                        selectedCategory?.allItems.append(newAppointment)
                    }
                }
                else {
                    for task in tasks {
                        let newTask = AllItems()
                        newTask.datetime = Date(timeIntervalSinceNow: TimeInterval(86400 * 31 * (task[0] as! Int)))
                        newTask.notes = task[1] as! String
                        newTask.uuid = UUID().uuidString
                        selectedCategory?.allItems.append(newTask)
                    }
                }
            }
        } catch {
            print(error)
        }
        
        configureTable(allTable)
    
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension AllViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableDict?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let dict = tableDict?[section] {
            return dict["count"] as! Int
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = allTable.dequeueReusableCell(withIdentifier: "allCell") as! AppointmentTableViewCell
        cell.date.text = formatter.string(from: items?[indexPath.row].datetime ?? Date())
        cell.info.text = items?[indexPath.row].notes ?? "No" + titleLabel.text!
        return cell
    }
    
    func configureTable(_ table : UITableView) {
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120.0
    }
}
