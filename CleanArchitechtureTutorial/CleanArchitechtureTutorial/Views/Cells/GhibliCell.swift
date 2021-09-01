//
//  GhibliCell.swift
//  CleanArchitechtureTutorial
//
//  Created by Khoa Mai on 9/1/21.
//

import Foundation
import UIKit
import SDWebImage

class GhibliCell: UITableViewCell {
    
    @IBOutlet weak private var titleLbl: UILabel!
    
    public var model: AnimeCellViewModel! {
        didSet {
            self.titleLbl.text = model.tilte
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
