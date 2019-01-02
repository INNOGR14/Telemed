//
//  WeightData.swift
//  Telemed
//
//  Created by Macbook on 12/26/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper

class Items : Object, Mappable {
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        datetime <- map["datetime"]
        data <- map["data"]
        notes <- map["notes"]
        uuid <- map["uuid"]
        creator <- map["creator"]
        byPT <- map["byPT"]
        updated <- map["updated"]
        
    }
    
    override static func primaryKey() -> String? {
        return "compoundKey"
    }
    

    @objc dynamic var compoundKey : String = ""
    @objc dynamic var datetime : Date = Date()
    @objc dynamic var data : Double = 0.0
    @objc dynamic var notes : String = ""
    @objc dynamic var uuid : String = ""
    @objc dynamic var creator : String = ""
    @objc dynamic var byPT : Bool = false
    @objc dynamic var updated : Bool = false
    let parentCategory = LinkingObjects(fromType: Trackers.self, property: "items")
    
}
