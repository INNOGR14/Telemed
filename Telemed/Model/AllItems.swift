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

class AllItems : Object, Mappable {
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        datetime <- map["datetime"]
        notes <- map["notes"]
        uuid <- map["uuid"]
        
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
    
    @objc dynamic var datetime : Date = Date()
    @objc dynamic var notes : String = ""
    @objc dynamic var uuid : String = ""
    @objc dynamic var updated : Bool = false
    let parentCategory = LinkingObjects(fromType: AllCategories.self, property: "allItems")
    
}
