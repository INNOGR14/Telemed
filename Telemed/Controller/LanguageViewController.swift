//
//  LanguageViewController.swift
//  Telemed
//
//  Created by Macbook on 1/20/19.
//  Copyright © 2019 drsocgr14. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func languageButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            
            appDelegate.language = "english"
            defaults.set(appDelegate.language, forKey: "language")
        }
        else if sender.tag == 2 {
            
            appDelegate.language = "thai"
            defaults.set(appDelegate.language, forKey: "language")
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
