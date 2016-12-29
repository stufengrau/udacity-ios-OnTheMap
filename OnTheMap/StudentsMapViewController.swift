//
//  StudentsMapViewController.swift
//  OnTheMap
//
//  Created by heike on 29/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import UIKit
import MapKit

class StudentsMapViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!

    var students: [StudentInformation] {
        return (UIApplication.shared.delegate as! AppDelegate).studentInformations
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentInformations()
    }
    
    private func getStudentInformations() {
        debugPrint("getStudentInformations called.")
        ParseAPI.sharedInstance().getStudentLocations { (networkRequestResult, studentInformations) in
            switch(networkRequestResult) {
            case .networkFailure:
                self.showAlert("Download of Student Informations failed. Try again later.")
            case .success:
                (UIApplication.shared.delegate as! AppDelegate).studentInformations = studentInformations
                debugPrint(self.students.count)
                self.refreshData()
            }
        }
    }
    
    private func createAnnotations() {
        
        debugPrint("createAnnotations called.")

        var annotations = [MKPointAnnotation]()
        
        for student in students {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        debugPrint(annotations.count)
        debugPrint(annotations[0])
        self.mapView.addAnnotations(annotations)

    }
    
    private func refreshData() {
        DispatchQueue.main.async {
            self.createAnnotations()
      }
    }
    
    private func showAlert(_ errormessage: String) {
        DispatchQueue.main.async {
            //self.enableUI(true)
            let alertController = UIAlertController(title: "", message: errormessage, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alertController.addAction(dismissAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
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
                UIApplication.shared.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
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
