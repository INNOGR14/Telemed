//
//  LoginViewController.swift
//  Telemed
//
//  Created by Macbook on 12/22/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import SwiftyJSON
import Alamofire
import SCLAlertView

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let server = Credentials.server
    
    let defaults = UserDefaults.standard
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unhandledError(status: OSStatus)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 10.0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        SVProgressHUD.show()

        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        do {
            guard status != errSecItemNotFound else { throw KeychainError.noPassword }
            guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
            guard let existingItem = item as? [String : Any],
                let passwordData = existingItem[kSecValueData as String] as? Data,
                let password = String(data: passwordData, encoding: String.Encoding.utf8),
                let account = existingItem[kSecAttrAccount as String] as? String
                else {
                    throw KeychainError.unexpectedPasswordData
            }
            let credentials = Credentials(username: account, password: password)

            let parametersDict : [String : Any] = ["username" : credentials.username, "password" : credentials.password]
            Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/userLogin", method: .post, parameters: parametersDict, encoding: JSONEncoding.default).responseJSON {
                response in

                switch response.result {

                case .success(let result):
                    if JSON(result)["result"].bool! {
                        print("Hello")
                        self.loginSuccess()
                    }
                    else {
                        print(response)
                        SCLAlertView().showError("Invalid credentials", subTitle: "Please login again")
                        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                                    kSecAttrServer as String: self.server]
                        let status = SecItemDelete(query as CFDictionary)
                        do {
                            guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
                        } catch {
                            print("Error deleting keychain data: \(error)")
                        }
                    }
                case .failure(let error):
                    print("Error connecting to login: \(error)")
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.addButton("Try Again") {
                        self.viewDidLoad()
                    }
                    alertView.addButton("Cancel") {

                    }
                    alertView.showError("Connection error", subTitle: "Please try again later")
                }
            }
        } catch {
            print(error)
            SCLAlertView().showNotice("You're logged out", subTitle: "Please sign in")
        }
        
        

        SVProgressHUD.dismiss()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    

    @IBAction func loginButtonPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: self.server]
        let status = SecItemDelete(query as CFDictionary)
        do {
            guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
        } catch {
            print("Error deleting keychain data: \(error)")
        }
        
        let parametersDict : [String : Any] = ["username" : emailTextField.text!, "password" : passwordTextField.text!]
        
        Alamofire.request("https://ide50-nobodysp.legacy.cs50.io:8080/userLogin", method: .post, parameters: parametersDict, encoding: JSONEncoding.default).responseJSON { (response) in
            
            print(response)
            
            switch response.result {
                
            case .success(let result):
                
                let responseState = JSON(result)["result"].bool!
                
                if responseState {
                    
                    do {
                        try self.configureKeychain()
                        print("hello")
                    } catch {
                        print("Keychain error \(error)")
                        SCLAlertView().showError("Internal system error", subTitle: "Please try again")
                    }
                    

                    self.loginSuccess()
                }
                else {
                    
                    SCLAlertView().showError("Login failed", subTitle: "Invalid credentials. Please try again.")
                    
//                    let action = UIAlertAction(title: "Try again", style: .default, handler: nil)
//                    let message = JSON(response.result.value!)["message"].string
//                    let alert = UIAlertController(title: "Login failed", message: message, preferredStyle: .alert)
//                    alert.addAction(action)
//                    self.present(alert, animated: true, completion: nil)
                }
            case .failure(let error):
                
                print("Error connecting to /login: \(error)")
                SCLAlertView().showError("Login failed", subTitle: "Network connection error. Please try again.")
            }
            
            
            self.view.endEditing(true)
            SVProgressHUD.dismiss()
            
        }
    
        
//        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
//            if error != nil {
//                print("Error registering: \(error!)")
//                SVProgressHUD.dismiss()
//            }
//            else {
//                print("success")
//                self.performSegue(withIdentifier: "goToHome", sender: self)
//                SVProgressHUD.dismiss()
//            }
//        }
        
    }
    
    func loginSuccess() {
        appDelegate.loginStatus = true
        defaults.set(appDelegate.loginStatus, forKey: "loginStatus")
        defaults.synchronize()
        
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let centerVC = mainStoryBoard.instantiateViewController(withIdentifier: "rootView") as! RootViewController
        appDelegate.window!.rootViewController = centerVC
        appDelegate.window!.makeKeyAndVisible()
        
    }
    
    func configureKeychain() throws {
        
        let credentials = Credentials(username: self.emailTextField.text!, password: self.passwordTextField.text!)
        let account = credentials.username
        let password = credentials.password.data(using: String.Encoding.utf8)!
        var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: account,
                                    kSecAttrServer as String: self.server,
                                    kSecValueData as String: password]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
    
}
