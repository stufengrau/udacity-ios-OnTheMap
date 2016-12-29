//
//  StudentsTableViewCell.swift
//  OnTheMap
//
//  Created by heike on 29/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import UIKit

class StudentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var studentsName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
