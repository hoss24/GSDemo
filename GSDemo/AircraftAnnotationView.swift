//
//  AircraftAnnotationView.swift
//  GSDemo
//
//  Created by Grant Matthias Hosticka on 10/21/21.
//

import Foundation
import MapKit

class AircraftAnnotationView: MKAnnotationView {

    // create a MKAnnotationView for the aircraft
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.isEnabled = false
        self.isDraggable = false
        self.image = UIImage(named: "aircraft.png")
    }

    //
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // method to change the aircraft's rotation
    public func update(heading: Float) {
        self.transform = CGAffineTransform.identity
        self.transform = CGAffineTransform(rotationAngle: CGFloat(heading))
    }
}
