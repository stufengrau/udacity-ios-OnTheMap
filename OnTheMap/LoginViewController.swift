//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by heike on 27/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        activityIndicatorView.hidesWhenStopped = true
    }

    // MARK: IBActions
    @IBAction func loginPressed(_ sender: UIButton) {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            showAlert("Empty Email or Password")
        } else {
            // if a username and password is provided disable Buttons and Text Fields
            // until an error occurs or the login is successful
            enableUI(false)
            loginToUdacity(emailTextField.text!, passwordTextField.text!)
        }
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        // open Udacity Sign Up Page in Safari
        let signUpURL = UdacityAPI.Constants.SignUpURL
        UIApplication.shared.open(URL(string: signUpURL)!, options: [:], completionHandler: nil)
    }
    
    // MARK: Text Field Delegate
    // dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: Helper functions
    // try login to Udacity an provide an error message if something goes wrong
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
    
    // if login is successful reset text fields and show the TabBarController View
    // with the Students Locations
    private func completeLogin() {
        DispatchQueue.main.async {
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "studentLocationsView")
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    // disable or enable UI Elements
    // and display an Activity View Indicator during the login process
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

