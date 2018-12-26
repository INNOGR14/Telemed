//
//  TrackerEnum.swift
//  Telemed
//
//  Created by Macbook on 12/26/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import Foundation


class TrackerEnum {
    
    var name : String
    var type : trackerData
    
    enum trackerData {
        
        case glucose
        case pressure
        case oxygen
        case pulse
        case height
        case weight
        
    }
    
    init(_ assignedName: String, _ assignedTrackerData: trackerData) {
        
        name = assignedName
        type = assignedTrackerData
        
    }
    
}
