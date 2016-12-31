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
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        activityIndicatorView.hidesWhenStopped = true
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
        let signUpURL = "https://www.udacity.com/account/auth#!/signup"
        UIApplication.shared.open(URL(string: signUpURL)!, options: [:], completionHandler: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func loginToUdacity(_ email: String, _ password: String) {
        
        UdacityAPI.sharedInstance().login(email: email, password: password) { (result) in
            self.enableUI(true)
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
    
    private func completeLogin() {
        DispatchQueue.main.async {
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "studentLocationsView")
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    private func enableUI(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.emailTextField.isEnabled = enabled
            self.passwordTextField.isEnabled = enabled
            self.loginButton.isEnabled = enabled
            self.signUpButton.isEnabled = enabled
            
            if enabled {
                self.activityIndicatorView.stopAnimating()
                self.loginButton.alpha = 1.0
            } else {
                self.activityIndicatorView.startAnimating()
                self.loginButton.alpha = 0.5
            }
        }
    }
    
}

