//
//  SyncData.swift
//  Telemed
//
//  Created by Macbook on 12/29/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON

class SyncData {
    
    static func retrieveTrackers (username: String, password: String, realm: Realm) {
        let formatter = DateFormatter()
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.dateFormat = "dd MMM yyyy hh:mm a"
        
        
        var trackersResults : Results<Trackers>?
        var updatedDatasResults : Results<UpdatedData>?
        
        trackersResults = realm.objects(Trackers.self)
        updatedDatasResults = realm.objects(UpdatedData.self)
        
        if let trackers = trackersResults {
            for tracker in trackers {
                let retrieveTrackersParam : [String : Any] = ["tracker" : tracker.name, "username" : username, "password" : password]
                
                Alamofire.request("https://ide50-nobodysp.cs50.io:8080/retrieveInfo", method: .post, parameters: retrieveTrackersParam , encoding: JSONEncoding.default).responseJSON {
                    response in
                    
                    
                    switch response.result {
                        
                    case .success(let items):
                        
                        if JSON(items)["result"].bool! {
                            
                            let itemArray = JSON(items)["content"].array!
                            var updatedItems : [[String : Any]]?
                            for item in itemArray {
                            
                                let itemDict = item.dictionaryObject
                                
                                if itemDict!["updated"] as! Bool == false {
                                    
                                    let newItem = Items(JSONString: item.rawString()!)!
                                    newItem.updated = true
                                    newItem.compoundKey = formatter.string(from: newItem.datetime) + String(newItem.byPT)
                                    
                                    var canAppend = true
                                    
                                    for trackerItem in tracker.items {
                                        if trackerItem.compoundKey == newItem.compoundKey {
                                            canAppend = false
                                            break
                                        }
                                    }
                                    
                                    if canAppend {
                                        do {
                                            try realm.write {
                                                
                                                tracker.items.append(newItem)
                                            }
                                        } catch {
                                            print("Error appending newItem to tarcker: \(error)")
                                        }
                                    }
                                    
                                    
                                    if updatedItems?.append(["tracker" : tracker.name, "uuid" : newItem.uuid]) == nil {
                                        updatedItems = [["tracker" : tracker.name, "uuid" : newItem.uuid]]
                                    }
                                    
                                }
                            }
                            
                            do {
                                try realm.write {
                                    tracker.lastUpdateIndex = tracker.items.count - 1
                                }
                            } catch {
                                print("Error changing lastUpdateIndex: \(error)")
                            }
                            
                            if updatedItems != nil {
                            
                                let syncUpdateParam : [String : Any] = ["username" : username, "password" : password, "updatedItems" : updatedItems!]
                                
                                Alamofire.request("https://ide50-nobodysp.cs50.io:8080/syncUpdate", method: .post, parameters: syncUpdateParam, encoding: JSONEncoding.default).responseJSON {
                                    response in
                                    
                                    switch response.result {
                                        
                                    case .success(let result):
                                        if JSON(result)["result"].bool! {
                                            
                                            print(result)
                                        }
                                        else {
                                            if let updatedDatas = updatedDatasResults {
                                                for item in updatedItems! {
                                                    let newUpdatedData = UpdatedData()
                                                    newUpdatedData.tracker = item["tracker"] as! String
                                                    newUpdatedData.uuid = item["uuid"] as! String
                                                    
                                                    var canUpdate = true
                                                    for data in updatedDatas {
                                                        if data.uuid == newUpdatedData.uuid {
                                                            canUpdate = false
                                                        }
                                                    }
                                                    
                                                    if canUpdate {
                                                        do {
                                                            try realm.write {
                                                                realm.add(newUpdatedData)
                                                            }
                                                        } catch {
                                                            print("Error saving UpdatedData: \(error)")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    case .failure(let error):
                                        
                                        print("Error connecting to /sync: \(error)")
                                        
                                        if let updatedDatas = updatedDatasResults {
                                        
                                            for item in updatedItems! {
                                                let newUpdatedData = UpdatedData()
                                                newUpdatedData.tracker = item["tracker"] as! String
                                                newUpdatedData.uuid = item["uuid"] as! String
                                                
                                                var canUpdate = true
                                                for data in updatedDatas {
                                                    if data.uuid == newUpdatedData.uuid {
                                                        canUpdate = false
                                                    }
                                                }
                                                
                                                if canUpdate {
                                                    do {
                                                        try realm.write {
                                                            realm.add(newUpdatedData)
                                                        }
                                                    } catch {
                                                        print("Error saving UpdatedData: \(error)")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                        else {
                            
                            print("Querying error")
                            print(items)
                            
                        }
                    case .failure(let error):
                        
                        print("Error connecting /retrieveInfo: \(error)")
                        
                    }
                    
                }
            }
        }
    }
    
    static func syncUpdate(username : String, password : String, realm: Realm, fromServer: Bool) {
        
        if fromServer == true {
            
            let updatedDataArray : Results<UpdatedData>?
            updatedDataArray = realm.objects(UpdatedData.self)
            
            
            if updatedDataArray != nil {
                
                var updatedItems : [[String : Any]]?
                
                for updatedData in updatedDataArray! {
                    
                    if updatedItems?.append(["tracker" : updatedData.tracker, "uuid" : updatedData.uuid]) == nil {
                        updatedItems = [["tracker" : updatedData.tracker, "uuid" : updatedData.uuid]]
                    }
                }
                if updatedItems != nil {
                    let syncUpdateParam : [String : Any] = ["username" : username, "password" : password, "updatedItems" : updatedItems!]
    
                    Alamofire.request("https://ide50-nobodysp.cs50.io:8080/syncUpdate", method: .post, parameters: syncUpdateParam, encoding: JSONEncoding.default).responseJSON {
                        response in
                        
                        switch response.result {
                            
                        case .success(let result):
                            
                            if JSON(result)["result"].bool! {
                                
                                for updatedData in updatedDataArray! {
                                    do {
                                        try realm.write {
                                            realm.delete(updatedData)
                                        }
                                    } catch {
                                        print("Error deleting UpdatedData: \(error)")
                                    }
                                }
                                print(result)
                            }
                            else {
                                print("Querying syncUpdate error")
                                print(result)
                            }
                        case .failure(let error):
                            print("Connection error with /syncUpdate: \(error)")
                        }
                        
                    }
                }
            }
            
            else if updatedDataArray == nil {
                print("nothing to update")
            }
            
        }
        else if fromServer == false {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let trackers = realm.objects(Trackers.self)
            for tracker in trackers {
                
                if tracker.needUpdate == true {
                    
                    var itemParamArray : [[String : Any]] = []
                    
                    for i in tracker.lastUpdateIndex...(tracker.items.count - 1) {
                        if tracker.items[i].updated == false {
                            let item = tracker.items[i]
                            var itemsParam : [String : Any] = [:]
                            itemsParam["datetime"] = formatter.string(from: item.datetime)
                            itemsParam["data"] = item.data
                            itemsParam["notes"] = item.notes
                            itemsParam["uuid"] = item.uuid
                            itemsParam["creator"] = item.creator
                            itemsParam["byPT"] = true
                            itemsParam["updated"] = true
                            itemParamArray.append(itemsParam)
                        }
                    }
                    
                    let addInfoParam : [String : Any] = ["username" : username, "password" : password, "tracker" : tracker.name, "items" : itemParamArray]
                    
                    Alamofire.request("https://ide50-nobodysp.cs50.io:8080/addInfo", method: .post, parameters: addInfoParam, encoding: JSONEncoding.default).responseJSON {
                        response in
                        
                        switch response.result {
                            
                        case .success(let result):
                            
                            if JSON(result)["result"].bool! {
                                
                                for i in tracker.lastUpdateIndex...(tracker.items.count - 1) {
                                    
                                    if tracker.items[i].updated == false {
                                        
                                        do {
                                            try realm.write {
                                                tracker.items[i].updated = true
                                            }
                                        } catch {
                                            print("Error changing updated status: \(error)")
                                        }
                                        
                                    }
                                }
                                
                                do {
                                    try realm.write {
                                        tracker.lastUpdateIndex = tracker.items.count - 1
                                    }
                                } catch {
                                    print("Error changing lastUpdateIndex: \(error)")
                                }
                                
                            }
                            
                            else {
                                
                                print("Query addinfo error or nothing to upload \(result)")
                            }
                        case .failure(let error):
                            print("Error connnecting to addinfo: \(error)")
                        }
                    }
                }
            }
        }
        
    }
    
    static func syncDelete(username: String, password: String, realm: Realm) {
        
        
        let syncDeleteParam : [String : Any] = ["username" : username, "password" : password, "tracker" : "", "uuid" : ""]
        
            Alamofire.request("https://ide50-nobodysp.cs50.io:8080/syncDelete", method: .post, parameters: syncDeleteParam, encoding: JSONEncoding.default).responseJSON {
                response in
                
                switch response.result {
                    
                case .success(let result):
                    if JSON(result)["result"].bool! {
                        let jsonArray = JSON(result)["deleteItems"].array!
                        var deleteArray : [[String : String]] = [[:]]
                        
                        for json in jsonArray {
                            deleteArray.append(["tracker" : json["tracker"].string!, "uuid" : json["uuid"].string!])
                        }
                        
                        
                        for deleteItem in deleteArray {
                            let selectedTracker = realm.objects(Trackers.self).filter("title CONTAINS %@", deleteItem["tracker"]!)[0]
                            for item in selectedTracker.items {
                                if item.uuid == deleteItem["uuid"] {
                                    do {
                                        try realm.write {
                                            realm.delete(item)
                                        }
                                    } catch {
                                        print("Error deleting item: \(error)")
                                    }
                                    break
                                }
                            }
                            selectedTracker.lastUpdateIndex = selectedTracker.items.count - 1
                        }
                        
                        
                    }
                    else {
                        print("Querying syncDelete error \(result)")
                    }
                case .failure(let error):
                    print("Error connecting to syncDelete \(error)")
                }
                
        }

    }
    
    static func retrieveAll(username: String, password: String) {
        
        let retrieveAllParam : [String : Any] = ["username" : username, "password" : password]
        
        Alamofire.request("https://ide50-nobodysp.cs50.io:8080/retrieveAll", method: .post, parameters: retrieveAllParam, encoding: JSONEncoding.default).responseJSON {
            response in
            
            switch response.result {
                
            case .success(let result):
                
                if JSON(result)["result"] == true {
//                    let appointments = JSON(result)["content"]["Appointments"].array
//                    let tasks = JSON(result)["content"]["Tasks"].array
                    
                }
                else {
                    print("Querying error for retrieveAll")
                    print(result)
                }
            
            case .failure(let error):
                print("Error connecting to retrieveAll \(error)")
            }
        }
    }
    
    
}
