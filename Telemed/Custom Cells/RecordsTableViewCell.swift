//
//  RecordsTableViewCell.swift
//  Telemed
//
//  Created by Macbook on 1/3/19.
//  Copyright © 2019 drsocgr14. All rights reserved.
//

import UIKit

class RecordsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var categoyLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
