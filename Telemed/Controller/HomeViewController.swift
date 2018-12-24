//
//  HomeViewController.swift
//  Telemed
//
//  Created by Macbook on 12/22/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//MARK - Declare instance variables
    
    let tableArray = ["FAQ", "Drugs", "Appointments"]
    
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var testLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        homeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "homeCell")
        
        getData()
        
    }
    
//MARK - TableView Datsource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
//        cell.textDescription.text = tableArray[indexPath.row]
        return cell
    }
    
//MARK - Logout Button Pressed
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        
        
        
//        do {
//            try Auth.auth().signOut()
//            navigationController?.popToRootViewController(animated: true)
//        } catch let signOutError as NSError {
//            print("Error signing out: \(signOutError)")
//        }
        
    }
    
    func getData() {
        Alamofire.request("https://ide50-nobodysp.cs50.io:8080/", method: .get).responseJSON{ (response) in
            print(response)
            if response.result.isSuccess {
                self.testLabel.text = JSON(response.result.value!)["hello"].string
            }
            else {
                print("Error retrieving info: \(response)")
            }
        }
    }
    
//    func getData() {
//        Alamofire.request("https://telemedapp.000webhostapp.com/checkusers.php", method: .get).responseString
//            { response in
//                let dictText = self.deleteString(response.description)
//                let dict = self.convertToDictionary(text: dictText)
//                self.testLabel.text = dict!["username"]! as! String
//
//        }
//    }
//
//    func deleteString(_ string: String) -> String {
//        var smth = string
//
//        if let index = (smth.range(of: "[")?.upperBound)
//        {
//            smth = String(smth.suffix(from: index))
//        }
//
//        if let index = (smth.range(of: "]")?.lowerBound)
//        {
//            smth = String(smth.prefix(upTo: index))
//        }
//
//        return smth
//    }
//
//    func convertToDictionary(text: String) -> [String: Any]? {
//        if let data = text.data(using: .utf8) {
//            do {
//                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//        return nil
//    }
    

}
