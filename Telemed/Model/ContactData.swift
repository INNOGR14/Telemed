//
//  ContactData.swift
//  Telemed
//
//  Created by Macbook on 12/27/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import Foundation
import RealmSwift

class ContactData: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var phoneNum = ""
    @objc dynamic var synced = false
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
}
