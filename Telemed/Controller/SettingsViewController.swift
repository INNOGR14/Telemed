//
//  SettingsViewController.swift
//  Telemed
//
//  Created by Macbook on 1/4/19.
//  Copyright © 2019 drsocgr14. All rights reserved.
//

import UIKit
import SVProgressHUD

class SettingsViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        logoutButton.layer.cornerRadius = 10.0
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        
        switch sender.tag {
        
        case 2:
            performSegue(withIdentifier: "goToLanguage", sender: self)
        default:
            print("hello")
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: Credentials.server]
        let status = SecItemDelete(query as CFDictionary)
        do {
            guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
        } catch {
            print("Error deleting keychain data: \(error)")
        }
        
        appDelegate.loginStatus = false
        defaults.set(appDelegate.loginStatus, forKey: "loginStatus")
        defaults.synchronize()
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginViewController
        
        appDelegate.window?.rootViewController = loginVC
        
        
        SVProgressHUD.dismiss()
    }
    
    
}
