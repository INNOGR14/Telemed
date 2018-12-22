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

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginButtonPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil {
                print("Error registering: \(error!)")
                SVProgressHUD.dismiss()
            }
            else {
                print("success")
                self.performSegue(withIdentifier: "goToHome", sender: self)
                SVProgressHUD.dismiss()
            }
        }
        
    }
    
}
