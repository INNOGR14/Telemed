//
//  HistoryTableViewCell.swift
//  Telemed
//
//  Created by Macbook on 12/30/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit
import Charts
import ChartsRealm
import RealmSwift
import ChameleonFramework

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var trackerName: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var intervalButtons: UISegmentedControl!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    var trackers : Results<Trackers>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func updateChart(tracker: Trackers, minimum: Double, maximum: Double, interval: Double, all: Bool) {

    
        var dataEntries = [ChartDataEntry]()
        
        let orderedItemsArray = tracker.items.sorted(byKeyPath: "datetime", ascending: true)
        
        for i in 0..<tracker.items.count {
            let timeIntervalForDate: TimeInterval  = orderedItemsArray[i].datetime.timeIntervalSince1970
            let dataEntry = ChartDataEntry(x: Double(timeIntervalForDate), y: Double(orderedItemsArray[i].data))
            dataEntries.append(dataEntry)
            
        }

        let chartDataSet = LineChartDataSet(values: dataEntries, label: tracker.name)
        chartDataSet.circleRadius = 6.0
        chartDataSet.circleHoleRadius = 3.0
        chartDataSet.lineWidth = 3.0
        chartDataSet.colors = [UIColor.flatBlueColorDark()]
        chartDataSet.drawValuesEnabled = false
        let chartData = LineChartData()
        chartData.addDataSet(chartDataSet)
        chartView.data = chartData
        
        
        let xaxis = chartView.xAxis
//        xaxis.axisMinimum = Date(timeIntervalSinceNow: -86400).timeIntervalSince1970
//        xaxis.axisMaximum = xaxis.axisMinimum + 86400
        
        if !all {
            
            xaxis.axisMinimum = minimum
            xaxis.axisMaximum = maximum
            xaxis.granularityEnabled = !all
            xaxis.granularity = interval
        }
        else {
            
            xaxis.axisMinimum = orderedItemsArray[0].datetime.timeIntervalSince1970
            xaxis.axisMaximum = orderedItemsArray[orderedItemsArray.count - 1].datetime.timeIntervalSince1970
            xaxis.granularityEnabled = all
        }
        
        xaxis.valueFormatter = axisFormatDelegate
    }


}
