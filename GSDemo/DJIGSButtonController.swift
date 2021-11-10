//
//  DJIGSButtonController.swift
//  GSDemo
//
//  Created by Grant Matthias Hosticka on 10/22/21.
//

import Foundation
import UIKit

//two different modes the application could be in
enum GSViewMode {
    case view
    case edit
}

protocol DJIGSButtonControllerDelegate : AnyObject {
    // delegate methods to be called by the delegate viewcontroller when IBAction methods for the buttons are triggered
    func stopBtnActionIn(gsBtnVC:DJIGSButtonController)
    func clearBtnActionIn(gsBtnVC:DJIGSButtonController)
    func focusMapBtnActionIn(gsBtnVC:DJIGSButtonController)
    func startBtnActionIn(gsBtnVC:DJIGSButtonController)
    func add(button:UIButton, actionIn gsBtnVC:DJIGSButtonController)
    func configBtnActionIn(gsBtnVC:DJIGSButtonController)
    func switchTo(mode:GSViewMode, inGSBtnVC:DJIGSButtonController)
}

class DJIGSButtonController : UIViewController {
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var editBtn: UIButton!
    @IBOutlet var addBtn: UIButton!
    @IBOutlet var focusMapBtn: UIButton!
    @IBOutlet var clearBtn: UIButton!
    @IBOutlet var startBtn: UIButton!
    @IBOutlet var stopBtn: UIButton!
    @IBOutlet var configBtn: UIButton!

    var mode = GSViewMode.view
    var delegate : DJIGSButtonControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init() {
        super.init(nibName:"DJIGSButtonController", bundle:Bundle.main)
    }
    
    convenience override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.init()
    }
    
    convenience required init?(coder: NSCoder) {
        self.init()
    }
    
    //MARK - Property Method
    //update the state of the buttons when the DJIGSViewMode changed
    func setMode(mode:GSViewMode) {
        self.mode = mode
        self.editBtn.isHidden = (mode == GSViewMode.edit)
        self.focusMapBtn.isHidden = (mode == GSViewMode.edit)
        self.backBtn.isHidden = (mode == GSViewMode.view)
        self.clearBtn.isHidden = (mode == GSViewMode.view)
        self.startBtn.isHidden = (mode == GSViewMode.view)
        self.stopBtn.isHidden = (mode == GSViewMode.view)
        self.addBtn.isHidden = (mode == GSViewMode.view)
        self.configBtn.isHidden = (mode == GSViewMode.view)
    }
        
    //MARK: - IBAction Methods
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.setMode(mode: GSViewMode.view)
        self.delegate?.switchTo(mode: self.mode, inGSBtnVC: self)
    }
    @IBAction func stopBtnAction(_ sender: UIButton) {
        self.delegate?.stopBtnActionIn(gsBtnVC: self)
    }
    
    @IBAction func clearBtnAction(_ sender: UIButton) {
        self.delegate?.clearBtnActionIn(gsBtnVC: self)
    }
    @IBAction func focusMapBtnAction(_ sender: UIButton) {
        self.delegate?.focusMapBtnActionIn(gsBtnVC: self)
    }
    @IBAction func editBtnAction(_ sender: UIButton) {
        self.setMode(mode: GSViewMode.edit)
        self.delegate?.switchTo(mode: self.mode, inGSBtnVC: self)
    }
    
    @IBAction func startBtnAction(_ sender: UIButton) {
        self.delegate?.startBtnActionIn(gsBtnVC: self)
    }
    
    @IBAction func addBtnAction(_ sender: UIButton) {
        self.delegate?.add(button: self.addBtn, actionIn: self)
    }
    @IBAction func configBtnAction(_ sender: UIButton) {
        self.delegate?.configBtnActionIn(gsBtnVC: self)
    }
}

