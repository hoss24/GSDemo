//
//  MapController.swift
//  GSDemo
//
//  Created by Grant Matthias Hosticka on 10/20/21.
//

import Foundation
import UIKit
import MapKit

class MapController : NSObject {

    var editPoints : [CLLocation]
    var editPoints2D : [CLLocationCoordinate2D]
    var aircraftAnnotation : AircraftAnnotation?
    var homePointAnnotation: MKPointAnnotation?

    override init() {
        self.editPoints = [CLLocation]() //for annotation
        self.editPoints2D = [CLLocationCoordinate2D]() //for mkpolyline between annotations
        super.init()
    }

    func add(point:CGPoint, for mapView:MKMapView) {
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.editPoints.append(location)
        self.editPoints2D.append(location.coordinate)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
        
        //add line between points
        let myPolyline = MKPolyline(coordinates: editPoints2D, count: editPoints2D.count)
        mapView.addOverlay(myPolyline)
        
    }
    
    func cleanAllPoints(with mapView: MKMapView) {
        self.editPoints.removeAll()
        self.editPoints2D.removeAll()
        let annotations = [MKAnnotation].init(mapView.annotations)
        for annotation : MKAnnotation in annotations {
            //prevent removal of aircraft annotation
            if annotation !== self.aircraftAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
        for overlay in mapView.overlays {
                mapView.removeOverlay(overlay)
        }
    }
    
    func updateAircraft(location:CLLocationCoordinate2D, with mapView:MKMapView) {
        if self.aircraftAnnotation == nil {
            self.aircraftAnnotation = AircraftAnnotation(coordinate: location)
            mapView.addAnnotation(self.aircraftAnnotation!)
        } else {
            UIView.animate(withDuration: 0.3) {
                self.aircraftAnnotation?.coordinate = location
            }
        }
    }
    
    func updateHome(location:CLLocationCoordinate2D, with mapView:MKMapView) {
        if self.homePointAnnotation == nil {
            homePointAnnotation = MKPointAnnotation()
            homePointAnnotation?.coordinate = location
            homePointAnnotation?.subtitle = "Home Point"
            mapView.addAnnotation(homePointAnnotation!)
            print("home point updated")
        } else {
            UIView.animate(withDuration: 0.1) {
                self.homePointAnnotation?.coordinate = location
            } completion: { _ in
                print("home point moved")
            }
        }
    }

    func updateAircraftHeading(heading:Float) {
        if let _ = self.aircraftAnnotation {
            self.aircraftAnnotation!.update(heading: heading)
        }
    }
}
