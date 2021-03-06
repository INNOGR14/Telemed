//
//  ConnectViewController.swift
//  Telemed
//
//  Created by Macbook on 12/27/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit
import RealmSwift


class ConnectViewController: UIViewController {
    
    let realm = try! Realm()
    
    var contacts : Results<ContactData>?
    var credentials : Credentials?

    @IBOutlet weak var connectTableView: UITableView!
    @IBOutlet weak var emergencyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emergencyView.layer.cornerRadius = 10.0
        
        connectTableView.delegate = self
        connectTableView.dataSource = self
        connectTableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "connectCell")
        
//        addContact()
        do {
            credentials = try GetCredentials.getUserPass()
        } catch {
            print("Error retrieving credentails: \(error)")
        }
        
        if let credentials = credentials {
            SyncData.retrieveContacts(username: credentials.username, password: credentials.password, realm: realm) {
                
                result in
                
                if result {
                    SyncData.syncUpdateContacts(username: credentials.username, password: credentials.password, realm: self.realm)
                    self.connectTableView.reloadData()
                    self.loadContacts()
                    self.configureTable(self.connectTableView)
                }
            }
        }
        
        loadContacts()
        configureTable(connectTableView)
        
        
    }
    
    func loadContacts() {
        
        contacts = realm.objects(ContactData.self)
        
    }
    
    func addContact() {
        
        let newContact = ContactData()
        newContact.name = "Dr. A"
        newContact.phoneNum = "0953296159"
        saveContact(newContact)
        
    }
    
    func saveContact(_ contact: ContactData) {
        
        do {
            try realm.write {
                realm.add(contact)
            }
        } catch {
            print("Error saving contact: \(error)")
        }
        
    }

    @IBAction func emergencyCallButonPressed(_ sender: Any) {
        
        if let url = URL(string: "tel://" + "999"), UIApplication.shared.canOpenURL(url) {
            
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
            
        }
    }
    
}

extension ConnectViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contacts?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "connectCell") as! ContactTableViewCell
        cell.name.text = contacts?[indexPath.section].name ?? "No contacts"
        cell.phoneNum = contacts?[indexPath.section].phoneNum ?? "0000000000"
        cell.layer.cornerRadius = 10
        cell.selectionStyle = .none
        return cell
    }
    
    func configureTable(_ table : UITableView) {
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

}
