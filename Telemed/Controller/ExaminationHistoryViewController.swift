//
//  ExaminationHistoryViewController.swift
//  Telemed
//
//  Created by Macbook on 12/30/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit
import ChartsRealm
import Charts
import RealmSwift


class ExaminationHistoryViewController: UIViewController {
    
    enum SelectedSegment: Int {
        case day = 0
        case week = 1
        case month = 2
        case year = 3
        case all = 4
    }
    var selectedSegment : [SelectedSegment]?
    
    let realm = try! Realm()
    var trackers : Results<Trackers>?
    let time = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: Date())
    var minimum : Double = 0
    var maximum : Double = 0
    var interval : Double = 0
    var numberOfIntervals : Double = 0
    var all = false
    var customFormatter = "HH:mm"
    var customIndex : IndexPath?
    
    @IBOutlet weak var historyTable: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        minimum = Date(timeIntervalSinceNow: -86400).timeIntervalSince1970 + TimeInterval(-(time.hour! * 3600 + time.minute! * 60 + time.second!))
        maximum = minimum + 86400
        numberOfIntervals = 8
        interval = (maximum - minimum) / numberOfIntervals
        
        loadTrackers()
        selectedSegment = [SelectedSegment](repeating: .day, count: trackers!.count)
        historyTable.delegate = self
        historyTable.dataSource = self
        historyTable.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "historyCell")
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadTrackers() {
        
        trackers = realm.objects(Trackers.self)
    }
    
    

}

extension ExaminationHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackers?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! HistoryTableViewCell
        cell.trackerName.text = trackers?[indexPath.row].name ?? "No trackers yet"
        cell.axisFormatDelegate = self as IAxisValueFormatter
        cell.intervalButtons.addTarget(self, action: #selector(segmentedControlValueChanged(segment:)), for: .valueChanged)
        
        if let allTrackers = trackers {
            
            cell.updateChart(tracker: allTrackers[indexPath.row], minimum: minimum, maximum: maximum, interval: interval, all: all)
        }
        cell.intervalButtons.selectedSegmentIndex = selectedSegment![indexPath.row].rawValue
        cell.selectionStyle = .none
        return cell
    }
    
    func configureTable(_ table : UITableView) {
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 330.0
    }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        
        let hitPoint = segment.convert(CGPoint.zero, to: historyTable)
        let indexPath = historyTable.indexPathForRow(at: hitPoint)
        
        switch segment.selectedSegmentIndex {
            
        case 0:
            selectedSegment![indexPath!.row] = SelectedSegment.day
            all = false
            minimum = Date(timeIntervalSinceNow: -86400).timeIntervalSince1970 + TimeInterval(-(time.hour! * 3600 + time.minute! * 60 + time.second!))
            maximum = minimum + 86400
            numberOfIntervals = 8
            interval = (maximum - minimum) / numberOfIntervals
            customFormatter = "HH:mm"
            historyTable.reloadRows(at: [indexPath!], with: UITableView.RowAnimation.none)
            
        case 1:
            selectedSegment![indexPath!.row] = SelectedSegment.week
            all = false
            minimum = Date(timeIntervalSinceNow: -86400 * 7).timeIntervalSince1970 + TimeInterval(-(time.hour! * 3600 + time.minute! * 60 + time.second!))
            maximum = minimum + 86400 * 7
            interval = 86400 * 2
            customFormatter = "dd/MM"
            historyTable.reloadRows(at: [indexPath!], with: UITableView.RowAnimation.none)
            
        case 2:
            selectedSegment![indexPath!.row] = SelectedSegment.month
            all = false
            if time.month! == 1 || time.month! == 3 || time.month! == 5 || time.month! == 7 || time.month! == 8 || time.month! == 10 || time.month! == 12 {
                minimum = Date(timeIntervalSinceNow: -86400 * 31).timeIntervalSince1970 + TimeInterval(-(time.hour! * 3600 + time.minute! * 60 + time.second!))
                maximum = minimum + 86400 * 31
            }
            else if time.month! == 2 {
                minimum = Date(timeIntervalSinceNow: -86400 * 28).timeIntervalSince1970 + TimeInterval(-(time.hour! * 3600 + time.minute! * 60 + time.second!))
                maximum = minimum + 86400 * 28
                
            }
            else {
                minimum = Date(timeIntervalSinceNow: -86400 * 30).timeIntervalSince1970 + TimeInterval(-(time.hour! * 3600 + time.minute! * 60 + time.second!))
                maximum = minimum + 86400 * 30
            }
            
            customFormatter = "dd/MM"
            interval = 86400*5
            
            historyTable.reloadRows(at: [indexPath!], with: UITableView.RowAnimation.none)
            
        case 3:
            selectedSegment![indexPath!.row] = SelectedSegment.year
            all = false
            minimum = Date(timeIntervalSinceNow: -86400 * 365).timeIntervalSince1970 + TimeInterval(-(time.hour! * 3600 + time.minute! * 60 + time.second!))
            maximum = minimum + 86400 * 365
            interval = 86400 * 61
            customFormatter = "MMM"
            historyTable.reloadRows(at: [indexPath!], with: UITableView.RowAnimation.none)
            
        case 4:
            selectedSegment![indexPath!.row] = SelectedSegment.all
            all = true
            customFormatter = "MMM YY"
            historyTable.reloadRows(at: [indexPath!], with: UITableView.RowAnimation.none)
            
        default:
            selectedSegment![indexPath!.row] = SelectedSegment.day
            all = false
            minimum = Date(timeIntervalSinceNow: -86400).timeIntervalSince1970 + TimeInterval(-(time.hour! * 3600 + time.minute! * 60 + time.second!))
            maximum = minimum + 86400
            numberOfIntervals = 8
            interval = (maximum - minimum) / numberOfIntervals
            historyTable.reloadRows(at: [indexPath!], with: UITableView.RowAnimation.none)
        }
        
    }
    
}

extension ExaminationHistoryViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dataFormatter = DateFormatter()
        
        dataFormatter.dateFormat = customFormatter
        
        return dataFormatter.string(from: Date(timeIntervalSince1970: value))
    }
    
}
