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
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorOuterView: UIView!
    
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var enterLinkStackView: UIStackView!
    @IBOutlet weak var mediaURL: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var submitInformationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var long: Double?
    var lat: Double?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        findLocationButton.isEnabled = false
        
        location.delegate = self
        mediaURL.delegate = self
        
        enterLinkStackView.isHidden = true
        
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorOuterView.isHidden = true
        
    }
    
    @IBAction func cancelPosting(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func acitvateLocationTextField(_ sender: UITapGestureRecognizer) {
        location.becomeFirstResponder()
    }
    
    @IBAction func findLocation(_ sender: UIButton) {
        
        guard let locationString = location.text else {
            assertionFailure("Impossible: location can not be empty after entering location")
            return
        }
        
        enableUI(false)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationString) { (placemarks, error) in
            
            self.enableUI(true)
            
            guard error == nil, let placemark = placemarks?[0],
                let coordinates = placemark.location?.coordinate else {
                    self.showAlert("Geocoding failed. Please try again.")
                    return
            }
            
            self.long = coordinates.longitude
            self.lat = coordinates.latitude
            
            self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
            self.mapView.region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpanMake(0.1, 0.1))
            
            self.locationStackView.isHidden = true
            self.enterLinkStackView.isHidden = false
            self.submitInformationButton.isEnabled = false

        }
    }
    
    @IBAction func submitInformation(_ sender: UIButton) {
    
    }

    private func enableUI(_ enabled: Bool) {
        DispatchQueue.main.async {
            
            if enabled {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorOuterView.isHidden = true
            } else {
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorOuterView.isHidden = false
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let location = location.text, !location.isEmpty {
            findLocationButton.isEnabled = true
        }
        
        if let mediaURL = mediaURL.text, !mediaURL.isEmpty {
            submitInformationButton.isEnabled = true
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
