//
//  AircraftAnnotation.swift
//  GSDemo
//
//  Created by Grant Matthias Hosticka on 10/21/21.
//

import Foundation
import MapKit

// The AircraftAnnotation class implements the MKAnnotation protocol.
// It's used to store and update a CLLocationCoordinate2D property.
// Also, we can update AircraftAnnotationView's heading with the updateHeading method.


//data needs to be represented as object conforming to the MKAnnotation protocol, with title, subtitle and coordinate as the required properties.
class AircraftAnnotation : NSObject, MKAnnotation {
    @objc dynamic var coordinate : CLLocationCoordinate2D
    var annotationView : AircraftAnnotationView?
    
    init(coordinate:CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
    
    func update(heading:Float) {
        self.annotationView?.update(heading: heading)
    }
}
