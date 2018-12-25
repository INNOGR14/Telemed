//
//  HistoryViewController.swift
//  Telemed
//
//  Created by Macbook on 12/25/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit
import RealmSwift
import Charts
import ChartsRealm

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var weightChart: LineChartView!
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    let realm = try! Realm()
    var weights: Results<WeightData>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        axisFormatDelegate = self
        
        for i in 1...5 {
            
            let weight = WeightData()
            weight.data = Double(i)
            saveWeight(weight)
            
        }
        
        updateWeightChart()
        

    }
    
    func saveWeight(_ data: WeightData) {
        
        do {
            try realm.write {
                realm.add(data)
            }
        } catch {
            print("Error saving data :\(error)")
        }
        
    }
    
    func loadWeightData() {
        weights = realm.objects(WeightData.self)
    }
    
    func updateWeightChart() {
        
        loadWeightData()
        var dataEntries = [ChartDataEntry]()
        
        for i in 0..<weights!.count {
            let timeIntervalForDate: TimeInterval  = weights![i].datetime.timeIntervalSince1970
            let dataEntry = ChartDataEntry(x: Double(timeIntervalForDate), y: Double(weights![i].data))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Weight")
        let chartData = LineChartData()
        chartData.addDataSet(chartDataSet)
        weightChart.data = chartData
        
        let xaxis = weightChart.xAxis
        xaxis.valueFormatter = axisFormatDelegate
    }

}

extension HistoryViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "HH:mm.ss"
        return dataFormatter.string(from: Date(timeIntervalSince1970: value))
    }
    
}
