//
//  AlertViewController.swift
//  GSDemo
//
//  Created by Grant Matthias Hosticka on 10/30/21.
//

import UIKit

class AlertViewController: UIViewController {
    
    @IBOutlet var alertText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func exitAlertSelected(_ sender: UIButton) {
    }
    
    
    init() {
        super.init(nibName: "AlertViewController", bundle: Bundle.main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
