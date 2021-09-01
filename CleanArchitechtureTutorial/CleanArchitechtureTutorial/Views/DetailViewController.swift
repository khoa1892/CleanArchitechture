//
//  DetailViewController.swift
//  CleanArchitechtureTutorial
//
//  Created by Khoa Mai on 9/1/21.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak private var textField: UITextView!
    
    public var model: Ghibli!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = model.toJSONString()
    }

}
