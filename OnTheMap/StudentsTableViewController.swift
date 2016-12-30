//
//  StudentsTableViewController.swift
//  OnTheMap
//
//  Created by heike on 29/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import UIKit

class StudentsTableViewController: UITableViewController {

    
//    var students: [StudentInformation] {
//        return (UIApplication.shared.delegate as! AppDelegate).studentInformations
//    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentInformations()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        UdacityAPI.sharedInstance().logout()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
        getStudentInformations()
    }
    
    @IBAction func pinLocationPressed(_ sender: UIBarButtonItem) {
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        debugPrint(ParseAPI.sharedInstance().studentInformations.count)
        return ParseAPI.sharedInstance().studentInformations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentName", for: indexPath)
        let student = ParseAPI.sharedInstance().studentInformations[indexPath.row]
        
        cell.detailTextLabel?.text = student.mediaURL
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.imageView?.image = UIImage(named: "PinIcon")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mediaURL = URL(string: ParseAPI.sharedInstance().studentInformations[indexPath.row].mediaURL) {
            UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
        }
    }
    
    private func getStudentInformations() {
        debugPrint("getStudentInformations called.")
        ParseAPI.sharedInstance().getStudentLocations { (networkRequestResult) in
            switch(networkRequestResult) {
            case .networkFailure:
                self.showAlert("Download of Student Informations failed. Try again later.")
            case .success:
                self.refreshData()
            }
        }
    }
    
    private func refreshData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
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


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
