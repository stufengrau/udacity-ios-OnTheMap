//
//  PostInformationViewController.swift
//  OnTheMap
//
//  Created by heike on 30/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import UIKit
import MapKit

class PostInformationViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorOuterView: UIView!
    
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var enterLinkStackView: UIStackView!
    @IBOutlet weak var mediaURL: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var submitInformationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var longitude: Double?
    var latitude: Double?
    
    var instanceOfStudentsLocationsVC: StudentsLocationsViewController?

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // disable Button until a location is entered
        findLocationButton.isEnabled = false
        
        location.delegate = self
        mediaURL.delegate = self
        
        // hide the second stackView until a location string
        // was successfully geocoded
        enterLinkStackView.isHidden = true
        
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorOuterView.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }


    // MARK: IBActions
    
    @IBAction func cancelPosting(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // location text field is placed inside another view
    // when user taps inside the view, activate text field
    @IBAction func acitvateLocationTextField(_ sender: UITapGestureRecognizer) {
        location.becomeFirstResponder()
    }
    
    // geocodes a location string
    @IBAction func findLocation(_ sender: UIButton) {
        
        // location should contain a value by now
        guard let locationString = location.text else {
            assertionFailure("Impossible: location can not be empty after entering location")
            return
        }
        
        // display an activity indicator
        enableUI(false)
        
        // geocode location string
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationString) { (placemarks, error) in
            
            self.enableUI(true)
            
            guard error == nil, let placemark = placemarks?[0],
                let coordinates = placemark.location?.coordinate else {
                    self.showAlert("Geocoding failed. Please try again.")
                    return
            }
            
            // extract longitude and latitude
            self.longitude = coordinates.longitude
            self.latitude = coordinates.latitude
            
            // add annotation to the map, center the map view around this coordinates
            // and set the span to zoom in
            self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
            self.mapView.region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpanMake(0.1, 0.1))
            
            // hide this stack view and enable the stack view 
            // to provide a link and to submit the new location
            self.locationStackView.isHidden = true
            self.enterLinkStackView.isHidden = false
            // button is disabled, until a url was entered
            self.submitInformationButton.isEnabled = false
        }
    }

    // Submits the new location
    @IBAction func submitInformation(_ sender: UIButton) {
        
        // all properties should be set by now
        guard let mediaURLString = mediaURL.text, let location = location.text, let latitude = latitude, let longitude = longitude else {
            assertionFailure("Impossible: mediaURL, location, longitude and latitude can not be empty after entering location and mediaURL")
            return
        }
        
        var checkedURL: String
        
        // make sure, that the url begins with a protocol
        if(doesURLBeginWithProtocol(url: mediaURLString)) {
            checkedURL = mediaURLString
        } else {
            checkedURL = prefixURLWithProtocol(url: mediaURLString)
        }
        
        // display an activity indicator
        enableUI(false)
        
        // try to post the new location (updateStudentLocation checks, if a location already exists and updates
        // the location, if needed)
        ParseAPI.sharedInstance().updateStudentLocation(location, checkedURL, latitude, longitude) { (networkRequestResult) in
            self.enableUI(true)
            switch(networkRequestResult) {
            case .networkFailure:
                self.showAlert("Posting your location failed. Please try again later.")
            case .success:
                // after dismissing the view, request new data from server
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        self.instanceOfStudentsLocationsVC?.getStudentsInformation()
                    })
                }
            }
        }
    }
    
    // MARK: Text Field Delegate
    // dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // enable buttons when text was entered in text fields
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let location = location.text {
            findLocationButton.isEnabled = !location.isEmpty
        }
        
        if let mediaURL = mediaURL.text {
            submitInformationButton.isEnabled = !mediaURL.isEmpty
        }
    }
    
    // MARK: NSNotification - Keyboard Notifications
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(PostInformationViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostInformationViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // location text field should be visible when editing -> shift view up
        if location.isEditing {
            locationStackView.frame.origin.y -= 100
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        locationStackView.frame.origin.y = 0
    }

    // MARK: Helper Methods
    // if UI should be disabled:
    // show a semitransparent view with an activity indicator
    // which overlays the main view
    func enableUI(_ enabled: Bool) {
        DispatchQueue.main.async {
            if enabled {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorOuterView.isHidden = true
            } else {
                self.activityIndicatorOuterView.isHidden = false
                self.activityIndicatorView.startAnimating()
            }
        }
    }

}
