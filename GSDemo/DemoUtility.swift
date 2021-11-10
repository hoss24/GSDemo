//
//  DemoUtility.swift
//  GSDemo
//
//  Created by Grant Matthias Hosticka on 10/21/21.
//

import Foundation
import DJISDK

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
}

func showAlert(on vc:UIViewController, title: String = "", message: String) {
    DispatchQueue.main.async {
        let alertViewController = UIAlertController(title: title, message: message as String, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alertViewController.addAction(okAction)
        vc.present(alertViewController, animated: true, completion: nil)
    }
}

func fetchFlightController() -> DJIFlightController? {
    if let aircraft = DJISDKManager.product() as? DJIAircraft {
        return aircraft.flightController
    }
    return nil
}

func fetchGimbal() -> [DJIGimbal]? {
    if let aircraft = DJISDKManager.product() as? DJIAircraft {
        return aircraft.gimbals
    }
    return nil
}
