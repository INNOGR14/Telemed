//
//  ProfileViewController.swift
//  Telemed
//
//  Created by Macbook on 12/25/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
