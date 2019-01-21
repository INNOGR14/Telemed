//
//  FAQTableViewCell.swift
//  Telemed
//
//  Created by Macbook on 1/4/19.
//  Copyright © 2019 drsocgr14. All rights reserved.
//

import UIKit

class FAQTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var header: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
