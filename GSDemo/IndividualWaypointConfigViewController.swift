//
//  IndividualWaypointConfigViewController.swift
//  GSDemo
//
//  Created by Grant Matthias Hosticka on 11/5/21.
//

import UIKit

protocol IndividualWaypointConfigViewControllerDelegate : AnyObject {
    func extendGimbalPitch(viewController : IndividualWaypointConfigViewController)
    func previousWaypointBtnActionInIndividualWaypointConfigViewController(viewController : IndividualWaypointConfigViewController)
    func nextWaypointBtnActionInIndividualWaypointConfigViewController(viewController : IndividualWaypointConfigViewController)
    func doneEditingIndivWaypointBtnActionInIndividualWaypointConfigViewController(viewController : IndividualWaypointConfigViewController)
}

class IndividualWaypointConfigViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var gimbalPitchLabel: UILabel!
    @IBOutlet var altitudeTextField: UITextField!
    @IBOutlet var gimbalPitchTextField: UITextField!
    @IBOutlet var currentWaypointLabel: UILabel!
    
    weak var delegate : IndividualWaypointConfigViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Do any additional setup after loading the view.
        altitudeTextField.delegate = self
        gimbalPitchTextField.delegate = self
    }
    
    func initUI() {
        //self.altitudeTextField.text = "20" //Set the altitude to 20
    }
    
    init() {
        super.init(nibName: "IndividualWaypointConfigViewController", bundle: Bundle.main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func previousWaypointBtnAction(_ sender: UIButton) {
        self.delegate?.previousWaypointBtnActionInIndividualWaypointConfigViewController(viewController:self)
    }
    
    @IBAction func nextWaypointBtnAction(_ sender: UIButton) {
        self.delegate?.nextWaypointBtnActionInIndividualWaypointConfigViewController(viewController:self)
    }
    
    @IBAction func extendGimbalPitchAction(_ sender: Any) {
        self.delegate?.extendGimbalPitch(viewController:self)
    }
    
    @IBAction func doneEditingIndivWaypointBtnAction(_ sender: Any) {
        self.delegate?.doneEditingIndivWaypointBtnActionInIndividualWaypointConfigViewController(viewController:self)
    }
}
