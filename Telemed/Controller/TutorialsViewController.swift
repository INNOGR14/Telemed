//
//  TutorialsViewController.swift
//  Telemed
//
//  Created by Macbook on 1/4/19.
//  Copyright © 2019 drsocgr14. All rights reserved.
//

import UIKit

class TutorialsViewController: UIViewController {
    
    @IBOutlet weak var addressLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        addressLabel.numberOfLines = 0
        addressLabel.sizeToFit()
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
