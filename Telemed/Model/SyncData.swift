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
    
    static func retrieveInfo (username: String, password: String, realm: Realm) {
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
                
                Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/retrieveInfo", method: .post, parameters: retrieveTrackersParam , encoding: JSONEncoding.default).responseJSON {
                    response in
                    
                    
                    switch response.result {
                        
                    case .success(let items):
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        
                        if JSON(items)["result"].bool! {
                            
                            let itemArray = JSON(items)["content"].array!
                            var updatedItems : [[String : Any]]?
                            for item in itemArray {
                            
                                let itemDict = item.dictionaryObject
                                
                                if itemDict!["updated"] as! Bool == false {
                                    
                                    let newItem = Items()
                                    let datetime = itemDict!["datetime"] as! String
                                    print(datetime)
                                    newItem.datetime = dateFormatter.date(from: datetime)!
                                    newItem.creator = itemDict!["creator"] as! String
                                    newItem.data = Double(itemDict!["data"] as! String)!
                                    newItem.notes = itemDict!["notes"] as! String
                                    newItem.uuid = itemDict!["uuid"] as! String
                                    newItem.byPT = itemDict!["byPT"] as! Bool
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
                                
                                Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/syncUpdate", method: .post, parameters: syncUpdateParam, encoding: JSONEncoding.default).responseJSON {
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
    
    static func syncItemUpdate(username : String, password : String, realm: Realm, fromServer: Bool) {
        
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
    
                    Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/syncUpdate", method: .post, parameters: syncUpdateParam, encoding: JSONEncoding.default).responseJSON {
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
                    
                    if tracker.items.count > 0 {
                    
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
                    }
                    let addInfoParam : [String : Any] = ["username" : username, "password" : password, "tracker" : tracker.name, "items" : itemParamArray]
                    
                    Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/addInfo", method: .post, parameters: addInfoParam, encoding: JSONEncoding.default).responseJSON {
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
        
            Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/syncDelete", method: .post, parameters: syncDeleteParam, encoding: JSONEncoding.default).responseJSON {
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
    
    static func retrieveAll(username: String, password: String, realm: Realm, completion: @escaping (_ result: Bool) -> ()) {
        
        let retrieveAllParam : [String : Any] = ["username" : username, "password" : password]
        
        Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/retrieveAll", method: .post, parameters: retrieveAllParam, encoding: JSONEncoding.default).responseJSON {
            response in
            
            switch response.result {
                
            case .success(let result):
                
                var allCategories : Results<AllCategories>
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                
                allCategories = realm.objects(AllCategories.self)
                
                if JSON(result)["resultAppointments"] == true {
                    
                    let allAppointments = allCategories.filter("name CONTAINS %@", "Appointments").first?.allItems
                    let appointments = JSON(result)["appointments"].array
                    
                    if let appointments = appointments {
                        for appointment in appointments {
                            
                            let appointmentDict = appointment.dictionaryObject
                            
                            if appointmentDict!["updated"] as! Bool == false {
                                
                                let newAppointment = AllItems()
                                let datetime = dateFormatter.date(from: appointmentDict!["datetime"] as! String)!
                                newAppointment.uuid = appointmentDict!["uuid"] as! String
                                newAppointment.datetime = datetime
                                newAppointment.notes = appointmentDict!["note"] as! String
                                newAppointment.updated = true
                                
                                if datetime >= Date() {
                                    
                                    var appendable = true
                                    
                                    for allAppointment in allAppointments! {
                                        if allAppointment.uuid == newAppointment.uuid {
                                            appendable = false
                                            break
                                        }
                                    }
                                    
                                    if appendable {
                                        do {
                                            try realm.write {
                                                allAppointments!.append(newAppointment)
                                            }
                                        } catch {
                                            print("Error saving new appointment to realm form server \(error)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    print("Querying error for retrieveAll")
                    print(result)
                }
                
                if JSON(result)["resultTasks"] == true {
                    
                    let allTasks = allCategories.filter("name CONTAINS %@", "Tasks").first?.allItems
                    let tasks = JSON(result)["tasks"].array
                    
                    if let tasks = tasks {
                        for task in tasks {
                            
                            let taskDict = task.dictionaryObject
                            
                            if taskDict!["updated"] as! Bool == false {
                                
                                let newTask = AllItems()
                                let datetime = dateFormatter.date(from: taskDict!["datetime"] as! String)!
                                newTask.uuid = taskDict!["uuid"] as! String
                                newTask.datetime = datetime
                                newTask.notes = taskDict!["note"] as! String
                                newTask.updated = true
                                
                                if datetime >= Date() {
                                    
                                    var appendable = true
                                    
                                    for allTask in allTasks! {
                                        if allTask.uuid == newTask.uuid {
                                            appendable = false
                                            break
                                        }
                                    }
                                    
                                    if appendable {
                                        do {
                                            try realm.write {
                                                allTasks!.append(newTask)
                                            }
                                        } catch {
                                            print("Error saving new task to realm form server \(error)")
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                else {
                    print("Querying error for retrieveAll")
                    print(result)
                }
                
                completion(true)
            
            case .failure(let error):
                print("Error connecting to retrieveAll \(error)")
                completion(false)
            }
        }
    }
    
    static func syncAllUpdate(username: String, password: String, realm: Realm) {
        
        let allCategories : Results<AllCategories>?
        
        allCategories = realm.objects(AllCategories.self)
        
        if let allCategories = allCategories {
            
            let tasks = allCategories.filter("name CONTAINS %@", "Tasks").first?.allItems
            let appointments = allCategories.filter("name CONTAINS %@", "Appointments").first?.allItems
            
            var taskUUIDs : [String]?
            var appointmentUUIDs : [String]?
            
            if let tasks = tasks {
                for task in tasks {
                    if taskUUIDs == nil {
                        taskUUIDs = [task.uuid]
                    }
                    else {
                        taskUUIDs!.append(task.uuid)
                    }
                }
            }
            if let appointments = appointments {
                for appointment in appointments {
                    if appointmentUUIDs == nil {
                        appointmentUUIDs = [appointment.uuid]
                    }
                    else {
                        appointmentUUIDs!.append(appointment.uuid)
                    }
                }
            }
            
            let syncAllUpdateParam : [String : Any] = ["username" : username, "password" : password, "updatedTasks" : taskUUIDs ?? [], "updatedAppointments" : appointmentUUIDs ?? []]
            
            Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/syncAllUpdate", method: .post, parameters: syncAllUpdateParam, encoding: JSONEncoding.default).responseJSON {
                
                response in
                
                switch response.result {
                    
                case .success(let result):
                    print(result)
                case .failure(let error):
                    print("error syncing all: \(error)")
                }
            }
        }
    }
    
    static func retrieveRecords(username: String, password: String, realm: Realm) {
        
        let retrieveRecordsParam : [String : Any] = ["username" : username, "password" : password]
        
        Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/retrieveRecords", method: .post, parameters: retrieveRecordsParam, encoding: JSONEncoding.default).responseJSON {
            response in
            
            switch response.result {
                
            case .success(let result):
                
                if JSON(result)["result"].bool! {
                    
                    if let contentArray = JSON(result)["content"].array {
                        
                        var recordsData : Results<RecordsData>?
                        recordsData = realm.objects(RecordsData.self)
                        
                        for content in contentArray {
                            if let record = content.dictionaryObject {
                                
                                var appendable = true
                                
                                if recordsData != nil {
                                    for recordData in recordsData! {
                                        if recordData.name == record["name"] as! String {
                                            appendable = false
                                            break
                                        }
                                    }
                                    
                                    if appendable {
                                        
                                        let newRecord = Items(JSONString: content.rawString()!)!
                                        
                                        do {
                                            try realm.write {
                                                realm.add(newRecord)
                                            }
                                        } catch {
                                            print("Error appending recordsData: \(error)")
                                        }
                                    }
                                    else {
                                        
                                        let selectedRecord = recordsData?.filter("name CONTAINS %@", record["name"] as! String)
                                        
                                        if selectedRecord != nil {
                                            selectedRecord!.first!.data = record["data"] as! String
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    print("Querying retrieveRecords error")
                    print(response)
                }
            case .failure(let error):
                print("Error connecting to retrieveRecords: \(error)")
            }
        }
    }
    
    static func retrievePatientInfo(username: String, password: String, defaults: UserDefaults) {
        
        let retrievePatientInfoParam : [String : Any] = ["username": username, "password" : password]
        
        Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/retrievePatientInfo", method: .post, parameters: retrievePatientInfoParam, encoding: JSONEncoding.default).responseJSON {
            
            response in
            
            switch response.result {
                
            case .success(let result):
                
                if JSON(result)["result"].bool! {
                    
                    let contentDict = JSON(result)["content"].dictionaryObject
                    
                    if let contentDict = contentDict {
                        
                        defaults.set(contentDict["fullName"] as! String, forKey: "fullName")
                        defaults.set(contentDict["patientID"] as! Int, forKey: "patientID")
                        defaults.set(contentDict["sex"] as! String, forKey: "sex")
                        defaults.set(contentDict["occupation"] as! String, forKey: "occupation")
                        
                        var birthdate = contentDict["birthdate"] as? String
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let formattedBirthdate = dateFormatter.date(from: birthdate ?? "") ?? Date()
                        let finalFormatter = DateFormatter()
                        finalFormatter.dateFormat = "dd-MMM-yyyy"
                        birthdate = finalFormatter.string(from: formattedBirthdate)
                        let calendar = Calendar.current
                        let ageComponents = calendar.dateComponents([.year, .month], from: formattedBirthdate, to: Date())
                        if let year = ageComponents.year {
                            if let month = ageComponents.month {
                                
                                let age = "\(year) years \(month) months"
                                defaults.set(age, forKey: "age")
                            }
                        }
                        
                        defaults.set(birthdate, forKey: "birthdate")
                    }
                }
                else {
                    print("Querying error? \(result)")
                }
            case .failure(let error):
                print("Error retrieving patient info: \(error)")
            }
        }
    }
    
    static func retrieveTrackers(username: String, password: String, realm: Realm, completion: @escaping (_ result: Bool) -> ()) {
        
        let retrieveTrackersParam : [String : Any] = ["username" : username, "password" : password]
        
        Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/retrieveTrackers", method: .post, parameters: retrieveTrackersParam, encoding: JSONEncoding.default).responseJSON {
            response in
            
            switch response.result {
                
            case .success(let result):
                let allTrackers : Results<Trackers>
                allTrackers = realm.objects(Trackers.self)
                
                let contents = JSON(result)["content"].array!
                
                for content in contents {
                    
                    if let tracker = content.dictionaryObject {
                        
                        if tracker["updated"] as! Bool == false {
                            
                            var addable = true
                            
                            for allTracker in allTrackers {
                                if allTracker.name == tracker["tracker"] as! String {
                                    addable = false
                                    break
                                }
                            }
                            
                            if addable {
                                do {
                                    try realm.write {
                                        let newTracker = Trackers()
                                        newTracker.name = tracker["tracker"] as! String
                                        
                                        realm.add(newTracker)
                                    }
                                } catch {
                                    print("Error writing new tracker to realm: \(error)")
                                }
                            }
                        }
                    }
                }
                
                completion(true)
            case .failure(let error):
                print("Error retrieving trackers: \(error)")
                completion(false)
            }
        }
    }
    
    static func syncTrackerUpdate(username: String, password: String, realm: Realm) {
        
        let allTrackers : Results<Trackers>
        
        allTrackers = realm.objects(Trackers.self)
        
        var trackerNames : [String]?
        
        for allTracker in allTrackers {
            
            if trackerNames == nil {
                trackerNames = [allTracker.name]
            }
            else {
                trackerNames!.append(allTracker.name)
            }
        }
        
        if let trackerNames = trackerNames {
            let syncUpdateTrackerParam : [String : Any] = ["username" : username, "password" : password, "updatedTrackers" : trackerNames]
            
            Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/syncUpdateTracker", method: .post, parameters: syncUpdateTrackerParam, encoding: JSONEncoding.default).responseJSON {
                
                response in
                
                switch response.result {
                    
                case .success(let result):
                    
                    if JSON(result)["result"].bool! == true {
                        print("successfully synced")
                        print(JSON(result)["message"])
                    }
                    else {
                        print(JSON(result)["message"])
                    }
                case .failure(let error):
                    print("Error syncing tracker with server: \(error)")
                }
            }
        }
        
    }
    
    static func retrieveContacts(username : String, password : String, realm : Realm, completion: @escaping (_ result: Bool) -> ()) {
        
        let retrieveContactsParam : [String : Any] = ["username" : username, "password" : password]
        
        Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/retrieveContacts", method: .post, parameters: retrieveContactsParam, encoding: JSONEncoding.default).responseJSON {
            
            response in
            
            switch response.result {
                
                
            case .success(let result):
                
                if JSON(result)["result"].bool! {
                    
                    var contactData : Results<ContactData>?
                    
                    contactData = realm.objects(ContactData.self)
                    
                    if let contactData = contactData {
                        
                        let retrievedArray = JSON(result)["content"].array ?? []
                        
                        for retrievedContact in retrievedArray {
                            
                            if let retrievedContact = retrievedContact.dictionaryObject {
                                
                                let contactName = retrievedContact["contactName"] as! String
                                let contactInfo = retrievedContact["contactInfo"] as! String
                                
                                var appendable = true
                                
                                for contact in contactData {
                                    
                                    if contact.name == contactName {
                                        appendable = false
                                        break
                                    }
                                }
                                
                                if appendable {
                                    
                                    do {
                                        try realm.write {
                                            let newContact = ContactData()
                                            newContact.name = contactName
                                            newContact.phoneNum = contactInfo
                                            newContact.synced = false
                                            realm.add(newContact)
                                        }
                                    } catch {
                                        print("Error adding contacts: \(error)")
                                    }
                                }
                                else {
                                    let filteredContact = contactData.filter("name CONTAINS %@", contactName).first
                                    do {
                                        try realm.write {
                                            filteredContact?.phoneNum = contactInfo
                                            filteredContact?.synced = false
                                        }
                                    } catch {
                                        print("Error updating contacts: \(error)")
                                    }
                                }
                                completion(true)
                            }
                        }
                    }
                }
                else {
                    print(result)
                }
            case .failure(let error):
                print("Error connecting to retrieveContacts: \(error)")
                completion(false)
            }
        }

    }
    
    static func syncUpdateContacts(username: String, password: String, realm: Realm) {
        
        var unsyncedContactArray : [String]?
        
        let allContacts : Results<ContactData>
        allContacts = realm.objects(ContactData.self)
        
        let unsyncedContacts = allContacts.filter("synced == %@", NSNumber(booleanLiteral: false))
        
        for unsyncedContact in unsyncedContacts {
            if unsyncedContactArray == nil {
                unsyncedContactArray = [unsyncedContact.name]
            }
            else {
                unsyncedContactArray!.append(unsyncedContact.name)
            }
        }
        
        let syncUpdateContactsParam : [String : Any] = ["username" : username, "password" : password, "updatedContacts" : unsyncedContactArray ?? []]
        
        Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/syncUpdateContacts", method: .post, parameters: syncUpdateContactsParam, encoding: JSONEncoding.default).responseJSON {
            
            response in
            
            switch response.result {
                
                
            case .success(let result):
                
                if JSON(result)["result"].bool! {
                    
                    for unsyncedContact in unsyncedContacts {
                        
                        do {
                            try realm.write {
                                unsyncedContact.synced = true
                            }
                        } catch {
                            print("Error updating unsyncedContacts: \(error)")
                        }
                    }
                }
                
            case .failure(let error):
                print("Error connecting to syncUpdateContacts: \(error)")
            }
            
        }
    }
}
