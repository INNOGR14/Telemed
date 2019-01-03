//
//  RecordsViewController.swift
//  Telemed
//
//  Created by Macbook on 1/3/19.
//  Copyright © 2019 drsocgr14. All rights reserved.
//

import UIKit
import RealmSwift

class RecordsViewController: UIViewController {
    
    @IBOutlet weak var recordsTable: UITableView!
    
    
    let realm = try! Realm()
    var recordsData : Results<RecordsData>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordsData = realm.objects(RecordsData.self)
        
        recordsTable.delegate = self
        recordsTable.dataSource = self
        
        recordsTable.register(UINib(nibName: "RecordsTableViewCell", bundle: nil), forCellReuseIdentifier: "recordsCell")
        
        configureTable(recordsTable)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension RecordsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsData?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordsCell") as! RecordsTableViewCell
        cell.categoyLabel.text = recordsData?[indexPath.row].name ?? "No records"
        cell.descriptionLabel.text = recordsData?[indexPath.row].data ?? "No records"
        return cell
    }
    
    func configureTable(_ table: UITableView) {
        
        table.estimatedRowHeight = 120.0
        table.rowHeight = UITableView.automaticDimension
    }
    
}