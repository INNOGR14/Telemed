//
//  RegisterViewController.swift
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

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    


    @IBAction func registerButtonPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        let parametersDict : [String : Any] = ["username" : emailTextField.text!, "password" : passwordTextField.text!]

//          Server method

        Alamofire.request("http://ide50-nobodysp.cs50.io:8080/register", method: .post, parameters: parametersDict, encoding: JSONEncoding.default).responseJSON { response in
            print(response)
            
            let responseState = JSON(response.result.value!)["result"].bool
            
            if responseState == true {
                self.callSegue()
            }
            else {
                let action = UIAlertAction(title: "Try again", style: .default, handler: nil)
                let message = JSON(response.result.value!)["message"].string
                let alert = UIAlertController(title: "Registration failed", message: message, preferredStyle: .alert)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }

            SVProgressHUD.dismiss()
        }
 
//          Firebase Method
        
//        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
//
//            if error != nil {
//                print("Error registering \(error!)")
//            }
//            else {
//                print("Registration successful")
//                self.performSegue(withIdentifier: "goToHome", sender: self)
//                SVProgressHUD.dismiss()
//            }
//
//        }
        
        
        
    }
    
    func callSegue() {
        performSegue(withIdentifier: "goToHome", sender: self)
    }
}
