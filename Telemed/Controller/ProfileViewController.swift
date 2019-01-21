//
//  ProfileViewController.swift
//  Telemed
//
//  Created by Macbook on 12/25/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let name = defaults.string(forKey: "fullName") ?? "No data"
        let id = defaults.integer(forKey: "userID")
        
        let dob = defaults.string(forKey: "birthdate") ?? "No data"
        let age = defaults.string(forKey: "age") ?? "No data"
        
        nameLabel.text! += name
        idLabel.text! += "\(id)"
        
        dobLabel.text! += dob
        ageLabel.text! += age
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func historyButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToHistory", sender: self)
    }
    @IBAction func recordButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToRecord", sender: self)
    }
    
}
