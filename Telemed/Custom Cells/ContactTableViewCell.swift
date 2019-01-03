//
//  ContactTableViewCell.swift
//  Telemed
//
//  Created by Macbook on 12/27/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    
    var phoneNum = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func messageButtonPressed(_ sender: Any) {
        
        //
        
    }
    
    @IBAction func callButtonPressed(_ sender: Any) {
        
        if let url = URL(string: "tel://" + phoneNum), UIApplication.shared.canOpenURL(url) {
            
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
            
        }
        
    }
    
}
