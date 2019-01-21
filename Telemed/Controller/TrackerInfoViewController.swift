//
//  TrackerInfoViewController.swift
//  Telemed
//
//  Created by Macbook on 12/26/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SCLAlertView
import ChameleonFramework

class TrackerInfoViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var infoField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dateTimeView: UIView!
    @IBOutlet var wholeView: UIView!
    
    var titleText = ""
    var infoFieldText = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let datePickerView = UIDatePicker()
    let timePickerView = UIDatePicker()
    
    var credentials : Credentials?
    
    let realm = try! Realm()
    
    var selectedTracker : Trackers?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        do {
            credentials = try GetCredentials.getUserPass()
        } catch {
            print(error)
        }
        
        SyncData.retrieveInfo(username: credentials?.username ?? "", password: credentials?.password ?? "", realm: realm)
        
        titleText = selectedTracker?.name ?? "No tracker"
        infoFieldText = selectedTracker?.name ?? "No tracker"
        
        dateField.delegate = self
        timeField.delegate = self
        infoField.delegate = self
        notesField.delegate = self
        
        infoField.keyboardType = UIKeyboardType.decimalPad
        
        addButton.isEnabled = false
        
        addButton.layer.cornerRadius = 10
        titleLabel.text = titleText
        
        infoField.attributedPlaceholder = NSAttributedString(string: infoFieldText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.flatBlue()])
        notesField.attributedPlaceholder = NSAttributedString(string: "Notes", attributes: [NSAttributedString.Key.foregroundColor: UIColor.flatBlue()])
        
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(self.dismissPicker))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (ViewTapped))
        wholeView.addGestureRecognizer(tapGesture)
        
        timePickerView.datePickerMode = .time
        datePickerView.datePickerMode = .date
        dateField.inputAccessoryView = toolBar
        timeField.inputAccessoryView = toolBar
        dateField.inputView = datePickerView
        timeField.inputView = timePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateField.text = dateFormatter.string(from: Date())
        timePickerView.addTarget(self, action: #selector(handleTimePicker(sender:)), for: .valueChanged)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        timeField.text = timeFormatter.string(from: Date())
        
    }
    
    @IBAction func dateTextFieldPressed(_ sender: UITextField) {
        
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        dateField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        
    }
    
    
    @IBAction func timeTextFieldPressed(_ sender: UITextField) {
        
        let timePickerView = UIDatePicker()
        timePickerView.datePickerMode = .time
        timeField.inputView = timePickerView
        timePickerView.addTarget(self, action: #selector(handleTimePicker(sender:)), for: .valueChanged)
        
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        
        if let currentTracker = selectedTracker {
            
            do {

                try realm.write {
    
                    let newItem = Items()
                    var canAppend = true
                    newItem.byPT = true
                    newItem.creator = "PT"
                    newItem.updated = false
                    newItem.data = infoToDouble()
                    newItem.datetime = textToDate()
                    newItem.notes = notesField.text!
                    newItem.uuid = UUID().uuidString
                    newItem.compoundKey = selectedTracker!.name + dateField.text! + " " + timeField.text! + String(true)
                    
                    if let tracker = selectedTracker {
                        
                        for item in tracker.items {
                            
                            if item.compoundKey == newItem.compoundKey {
                                canAppend = false
                                break
                            }
                        }
                    }
                    
                    if canAppend {
                        
                        currentTracker.items.append(newItem)
                        currentTracker.needUpdate = true
                        
                        infoField.text = ""
                        notesField.text = ""
                        SCLAlertView().showSuccess("Success!", subTitle: "Data added")
                        SyncData.syncItemUpdate(username: credentials?.username ?? "", password: credentials?.password ?? "", realm: realm, fromServer: false)
                    }
                    else {
                        SCLAlertView().showError("Failed", subTitle: "\(selectedTracker!.name) data at at this time already exists. Please change the time.")
                    }
                    
                }
                
            } catch {
                
                print("Error adding new item: \(error)")
                SCLAlertView().showError("Failed", subTitle: "Error adding new data \nPlease try again")
            }
            
        }
        else {
            print("No tracker set")
            SCLAlertView().showError("Failed", subTitle: "No tracker selected \nPlease go back and add a tracker")
        }
        
        endEditing()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        endEditing()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func handleTimePicker(sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        timeField.text = timeFormatter.string(from: sender.date)
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    @objc func ViewTapped() {
        endEditing()
    }

    //Convert text in textfield to date type
    func textToDate() -> Date {
        
        let saveFormatter = DateFormatter()
        saveFormatter.dateFormat = "dd MMM yyyy hh:mm a"
        saveFormatter.timeZone = TimeZone(abbreviation: "GMT+07:00")
        
        let dateTimeString = dateField.text! + " " + timeField.text!
        
        guard let date = saveFormatter.date(from: dateTimeString) else {
            fatalError()
        }
        
        return date
        
    }
    
    //Convert text in infoField to double type
    func infoToDouble() -> Double {
        
        guard let data = infoField.text!.toDouble() else {
            fatalError()
        }
        
        return data
    }
    
    func endEditing() {
        dateField.endEditing(true)
        timeField.endEditing(true)
        infoField.endEditing(true)
        notesField.endEditing(true)
    }
    
}

extension TrackerInfoViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        
        if textField == infoField {
            
            let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            
            if text.toDouble() != nil {
                addButton.isEnabled = true
            }
            else {
                addButton.isEnabled = false
            }
            
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        return true
        
    }
    
}


//MARK: - Format Number
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

//MARK: - Done button
extension UIToolbar {
    
    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}

