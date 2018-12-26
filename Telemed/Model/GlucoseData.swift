//
//  GlucoseData.swift
//  Telemed
//
//  Created by Macbook on 12/27/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import Foundation
import RealmSwift

class GlucoseData : Object {
    
    @objc dynamic var datetime : Date = Date()
    @objc dynamic var data : Double = 0.0
    @objc dynamic var notes : String = ""
    
}
