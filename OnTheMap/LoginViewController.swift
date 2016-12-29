//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by heike on 27/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }


    @IBAction func loginPressed(_ sender: UIButton) {
        
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            showAlert("Empty Email or Password")
        } else {
            enableUI(false)
            loginToUdacity(emailTextField.text!, passwordTextField.text!)
        }
        
    }
    
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://www.udacity.com/account/auth#!/signup")!, options: [:], completionHandler: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func loginToUdacity(_ email: String, _ password: String) {
        
        UdacityAPI.sharedInstance().login(email: email, password: password) { (result) in
            switch(result) {
            case .networkFailure:
                self.showAlert("Network failure")
            case .loginFailure:
                self.showAlert("Invalid Email or Password")
            case .success:
                self.completeLogin()
            }
        }
    }
    

    private func showAlert(_ errormessage: String) {
        DispatchQueue.main.async {
            self.enableUI(true)
            let alertController = UIAlertController(title: "", message: errormessage, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alertController.addAction(dismissAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func completeLogin() {
        DispatchQueue.main.async {
            self.enableUI(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "testLoginView")
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    private func enableUI(_ enabled: Bool) {
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        signUpButton.isEnabled = enabled
        
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
}

