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
            items = selectedCategory?.allItems.sorted(byKeyPath: "datetime", ascending: false)
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
                    
                    let formattedTime = dayFormatter.string(from: item.datetime)
                    if tableDict == nil {
                        tableDict = [["date" : formattedTime, "count" : 1]]
                    }
                    else {
                        var appendable = true
                        
                        for (index, element) in tableDict!.enumerated() {
                            if element["date"] as! String == formattedTime {
                                appendable = false
                                tableDict![index]["count"] = tableDict![index]["count"] as! Int + 1
                            }
                        }
                        if appendable {
                            tableDict!.append(["date" : formattedTime, "count" : 1])
                        }
                    }
                    if tableDict != nil {
                        tableDict = tableDict!.sorted(by: { dayFormatter.date(from: $0["date"] as! String)! > dayFormatter.date(from: $1["date"] as! String)! })
                    }
                }
            }
            else {
                formatter.dateFormat = "dd MMM yyyy hh:mm a"
                dayFormatter.dateFormat = "MMM YYYY"
                timeFormatter.dateFormat = "EEE dd hh:mm a"
                
                for item in currentCategory.allItems {

                    let formattedTime = dayFormatter.string(from: item.datetime)
                    if tableDict == nil {
                        tableDict = [["date" : formattedTime, "count" : 1]]
                    }
                    else {
                        var appendable = true
                        
                        for (index, element) in tableDict!.enumerated() {
                            if element["date"] as! String == formattedTime {
                                appendable = false
                                tableDict![index]["count"] = tableDict![index]["count"] as! Int + 1
                            }
                        }
                        if appendable {
                            tableDict!.append(["date" : formattedTime, "count" : 1])
                            print(formattedTime)
                        }
                    }
                    if tableDict != nil {
                        tableDict = tableDict!.sorted(by: { dayFormatter.date(from: $0["date"] as! String)! > dayFormatter.date(from: $1["date"] as! String)! })
                    }
                }
            }
        }
        
//        do {
//            try realm.write {
//                if selectedCategory?.name == "Appointments" {
//                    for appointment in appointments {
//                        let newAppointment = AllItems()
//                        newAppointment.datetime = Date(timeIntervalSinceNow: TimeInterval(3600 * (appointment[0] as! Int)))
//                        newAppointment.notes = appointment[1] as! String
//                        newAppointment.uuid = UUID().uuidString
//                        selectedCategory?.allItems.append(newAppointment)
//                        let anotherAppointment = AllItems()
//                        anotherAppointment.datetime = newAppointment.datetime
//                        anotherAppointment.notes = appointment[1] as! String
//                        anotherAppointment.uuid = UUID().uuidString
//                        selectedCategory?.allItems.append(anotherAppointment)
//                    }
//                }
//                else {
//                    for task in tasks {
//                        let newTask = AllItems()
//                        newTask.datetime = Date(timeIntervalSinceNow: TimeInterval(86400 * 31 * (task[0] as! Int)))
//                        newTask.notes = task[1] as! String
//                        newTask.uuid = UUID().uuidString
//                        selectedCategory?.allItems.append(newTask)
//                        let anotherTask = AllItems()
//                        anotherTask.datetime = newTask.datetime
//                        anotherTask.notes = task[1] as! String
//                        anotherTask.uuid = UUID().uuidString
//                        selectedCategory?.allItems.append(anotherTask)
//                    }
//                }
//            }
//        } catch {
//            print(error)
//        }
        
        configureTable(allTable)
    
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
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = allTable.dequeueReusableCell(withIdentifier: "allCell") as! AppointmentTableViewCell
        var startingIndex = 0
        if let dict = tableDict {
            for i in 0..<indexPath.section {
                startingIndex += dict[i]["count"] as! Int
            }
        }
        if (items?.count ?? 0) - 1 >= startingIndex + indexPath.row {
            cell.date.text = " " + timeFormatter.string(from: items?[indexPath.row + startingIndex].datetime ?? Date())
            cell.info.text = " " + (items?[indexPath.row + startingIndex].notes ?? "No" + titleLabel.text!)
        }
        else {
            cell.date.text = " " + ("No " + titleLabel.text!)
            cell.info.text = " " + ("No " + titleLabel.text!)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let dict = tableDict?[section] {
            return dict["date"] as! String
        }
        else {
            return "No section"
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        headerView.backgroundColor = UIColor.lightGray
        
        let headerLabel = UILabel(frame: CGRect(x: 8, y: 0, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont(name: "Helvetica", size: 30)
        headerLabel.textColor = UIColor.white
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func configureTable(_ table : UITableView) {
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120.0
        table.sectionHeaderHeight = UITableView.automaticDimension
        table.estimatedSectionHeaderHeight = 40.0
    }
}
