//
//  StudentsMapViewController.swift
//  OnTheMap
//
//  Created by heike on 29/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//
//  This class reuses some code from Udacity Project PinSample
//

import UIKit
import MapKit

class StudentsMapViewController: StudentsLocationsViewController, MKMapViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorOuterView: UIView!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorOuterView.isHidden = true
        
        // the map view is the first view after a successful login
        // -> get Students Information for initial data load
        getStudentsInformation()
    }
    
    // only refreshes data for the view, no new data is requested via http request
    // e.g. if new data was requested from the server by another view, 
    // this view will show the updated data
    override func viewWillAppear(_ animated: Bool) {
        refreshData()
    }
    
    // MARK: IBActions
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        logoutAndDismiss()
    }
    
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
        getStudentsInformation()
    }
    
    @IBAction func pinLocationPressed(_ sender: UIBarButtonItem) {
        checkStudentLocation()
    }
    
    // MARK: MKMapViewDelegate
    
    // Create a view with a "right callout accessory view".
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            if let toOpen = view.annotation?.subtitle! {
                if let mediaURL = URL(string: toOpen) {
                    UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    // MARK: Helper Methods
    
    // Create Annotations to view on the map
    private func createAnnotations() {
        
        var annotations = [MKPointAnnotation]()
        
        // iterate over the Student Information Array to create the annotations
        for student in StudentInfoModel.sharedInstance().studentInformations {
            
            // create CLLocationDegree values
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            // create a CLLocationCoordinates2D instance
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Create the annotation and set its coordiate
            // title to the full name of the student
            // subtitle to the provided url
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            
            annotations.append(annotation)
        }
        
        // Delete old annoations before adding new ones
        mapView.removeAnnotations(self.mapView.annotations)
        mapView.addAnnotations(annotations)
    
    }
    
    // create new annotations array to display changes
    override func refreshData() {
        DispatchQueue.main.async {
            self.createAnnotations()
        }
    }
    
    // if UI should be disabled:
    // show a semitransparent view with an activity indicator
    // which overlays the main view
    override func enableUI(_ enabled: Bool) {
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
