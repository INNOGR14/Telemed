//
//  FAQInfoViewController.swift
//  Telemed
//
//  Created by Macbook on 1/20/19.
//  Copyright © 2019 drsocgr14. All rights reserved.
//

import UIKit

class FAQInfoViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    var faqTitleText : NSMutableAttributedString?
    var infoText : NSMutableAttributedString?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let infoText = infoText {
            infoLabel.attributedText = infoText
        }
        
        if let faqTitleText = faqTitleText {
            
            titleLabel.attributedText = faqTitleText
        }
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
