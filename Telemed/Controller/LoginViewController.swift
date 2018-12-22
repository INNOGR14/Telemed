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

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginButtonPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        let parametersDict : [String : Any] = ["username" : emailTextField.text!, "password" : passwordTextField.text!]
        
        Alamofire.request("https://ide50-nobodysp.cs50.io:8080/login", method: .post, parameters: parametersDict, encoding: JSONEncoding.default).responseJSON { (response) in
            
            print(response)
            
            let responseState = JSON(response.result.value!)["result"].bool
            
            if responseState == true {
//                self.callSegue()
            }
            else {
                let action = UIAlertAction(title: "Try again", style: .default, handler: nil)
                let message = JSON(response.result.value!)["message"].string
                let alert = UIAlertController(title: "Login failed", message: message, preferredStyle: .alert)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
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
    
    func callSegue() {
        performSegue(withIdentifier: "goToHome", sender: self)
    }
    
}
