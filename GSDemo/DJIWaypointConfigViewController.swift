//
//  DJIWaypointConfigViewController.swift
//  GSDemo
//
//  Created by Grant Matthias Hosticka on 10/25/21.
//

import Foundation
import UIKit

protocol DJIWaypointConfigViewControllerDelegate : AnyObject {
    func cancelBtnActionInDJIWaypointConfigViewController(viewController : DJIWaypointConfigViewController)
    func finishBtnActionInDJIWaypointConfigViewController(viewController : DJIWaypointConfigViewController)
    func editIndividuallyBtnActionInDJIWaypointConfigViewController(viewController : DJIWaypointConfigViewController)
    func editRouteBtnActionInDJIWaypointConfigViewController(viewController : DJIWaypointConfigViewController)
}

class DJIWaypointConfigViewController : UIViewController, UITextFieldDelegate {
    @IBOutlet weak var altitudeTextField: UITextField!
    @IBOutlet weak var autoFlightSpeedTextField: UITextField!
    @IBOutlet weak var maxFlightSpeedTextField: UITextField!
    @IBOutlet weak var actionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var headingSegmentedControl: UISegmentedControl!

    weak var delegate : DJIWaypointConfigViewControllerDelegate?
    
    init() {
        super.init(nibName: "DJIWaypointConfigViewController", bundle: Bundle.main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        
        altitudeTextField.delegate = self
        autoFlightSpeedTextField.delegate = self
        maxFlightSpeedTextField.delegate = self
    }

    func initUI() {
        self.altitudeTextField.text = "20" //Set the altitude to 20
        self.autoFlightSpeedTextField.text = "8" //Set the autoFlightSpeed to 8
        self.maxFlightSpeedTextField.text = "10" //Set the maxFlightSpeed to 10
        self.actionSegmentedControl.selectedSegmentIndex = 1 //Set the finishAction to DJIWaypointMissionFinishedGoHome
        self.headingSegmentedControl.selectedSegmentIndex = 0 //Set the headingMode to DJIWaypointMissionHeadingAuto
        
    }

    @IBAction func cancelBtnAction(_ sender: Any) {
        self.delegate?.cancelBtnActionInDJIWaypointConfigViewController(viewController:self)
    }

    @IBAction func finishBtnAction(_ sender: Any) {
        self.delegate?.finishBtnActionInDJIWaypointConfigViewController(viewController: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func editIndividuallyBtnAction(_ sender: Any) {
        self.delegate?.editIndividuallyBtnActionInDJIWaypointConfigViewController(viewController: self)
    }
    
    @IBAction func editRouteBtnAction(_ sender: UIButton) {
        self.delegate?.editRouteBtnActionInDJIWaypointConfigViewController(viewController: self)
    }
    
    
    
}

