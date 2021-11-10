//
//  RootViewController.swift
//  GSDemo
//
//  Created by Grant Matthias Hosticka on 10/20/21.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import DJISDK

class RootViewController : UIViewController, DJISDKManagerDelegate, DJIFlightControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, DJIGSButtonControllerDelegate, DJIWaypointConfigViewControllerDelegate, IndividualWaypointConfigViewControllerDelegate, DJIGimbalDelegate {
    
    
    
    var mapController: MapController?
    var isEditingPoints = false
    var locationManager : CLLocationManager?
    var userLocation : CLLocationCoordinate2D?
    var droneLocation : CLLocationCoordinate2D?
    var homeLocation : CLLocationCoordinate2D?
    var gsButtonVC: DJIGSButtonController?
    var waypointConfigVC : DJIWaypointConfigViewController?
    var indWaypointConfigVC: IndividualWaypointConfigViewController?
    var waypointMission : DJIMutableWaypointMission?
    var alertViewsShowing: Int = 0
    var currentIndividualWaypointEditing = 0
    var gimbalPitchMin = -90
    var gimbalPitchMax = 0
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var topBarView: UIStackView!
    
    @IBOutlet var modeLabel: UILabel!
    @IBOutlet var gpsLabel: UILabel!
    @IBOutlet var hsLabel: UILabel!
    @IBOutlet var vsLabel: UILabel!
    @IBOutlet var altitudeLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startUpdateLocation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager?.stopUpdatingLocation()
    }


    func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    //MARK:  Init Methods
    func initData() {
        userLocation = kCLLocationCoordinate2DInvalid
        droneLocation = kCLLocationCoordinate2DInvalid
        
        modeLabel.text = "N/A"
        gpsLabel.text = "0"
        vsLabel.text = "0.0 M/S"
        hsLabel.text = "0.0 M/S"
        altitudeLabel.text = "0 M"
        
        mapController = MapController()
        // Initialize Tap Gesture Recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addWaypoints(tapGesture:)))
        // Add Tap Gesture Recognizer
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        self.gsButtonVC = DJIGSButtonController()
        if let gsButtonVC = self.gsButtonVC {
            //calculate top padding (safearea)
            var topPadding: CGFloat = 0.0
            let window = UIApplication.shared.windows.first
            if let safeTopPadding = window?.safeAreaInsets.top {
                topPadding = safeTopPadding
            }

            gsButtonVC.view.frame = CGRect(x: 0.0,
                                           y: self.topBarView.frame.origin.y + self.topBarView.frame.size.height + topPadding,
                                           width: self.gsButtonVC!.view.frame.size.width,
                                           height: self.gsButtonVC!.view.frame.size.height)
            gsButtonVC.delegate = self
            self.view.addSubview(self.gsButtonVC!.view)
        }
        
        waypointConfigVC = DJIWaypointConfigViewController()
        //hide view
        waypointConfigVC?.view.alpha = 0
        waypointConfigVC?.view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        waypointConfigVC?.view.center = self.view.center
        //center location on iPad in vc
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            self.waypointConfigVC?.view.center = self.view.center
        }
        self.waypointConfigVC?.delegate = self
        if let _ = self.waypointConfigVC {
            self.view.addSubview(self.waypointConfigVC!.view)
        }
        
        indWaypointConfigVC = IndividualWaypointConfigViewController()
        //hide view
        indWaypointConfigVC?.view.alpha = 0
        indWaypointConfigVC?.view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        indWaypointConfigVC?.view.center = self.view.center
        //center location on iPad in vc
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            self.indWaypointConfigVC?.view.center = self.view.center
        }
        self.indWaypointConfigVC?.delegate = self
        if let _ = self.indWaypointConfigVC {
            self.view.addSubview(self.indWaypointConfigVC!.view)
        }
        indWaypointConfigVC?.gimbalPitchLabel.text = "Gimbal Pitch (\(gimbalPitchMin) to \(gimbalPitchMax))"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        
        DJISDKManager.registerApp(with: self)
    }
    
    //MARK: - Button Actions
    func focusMap() {
        /*guard let userLocation = self.userLocation else {
            return
        }*/
        
        guard let droneLocation = self.droneLocation else {
            return
        }
        
        if CLLocationCoordinate2DIsValid(droneLocation) {
            let center = CLLocationCoordinate2D(latitude: droneLocation.latitude, longitude: droneLocation.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
            let region = MKCoordinateRegion(center: center, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    //MARK: - Alert SubView
    func showAlertSubView(with text: String, color: UIColor) {
        let alertView = AlertViewController()
        
        //calculate top padding of the safearea)\
        var topPadding: CGFloat = 0.0
        let window = UIApplication.shared.windows.first
        if let safeTopPadding = window?.safeAreaInsets.top {
            topPadding = safeTopPadding
        }
        
        //use counter variable for setting alert sub view tag
        var counter = alertViewsShowing
        
        //move current alert down to make room for new one at top
        for view in view.subviews {
            //filter alert subviews as they have been assigned a tag, all other default as 0
            if view.tag > 0 {
                //reset tag number to reflect order
                view.tag = counter + 1
                UIView.animate(withDuration: 0.2) {
                    //use tag number to calculate how far down alert should be moved
                    view.transform = CGAffineTransform( translationX: 0.0, y: CGFloat(alertView.view.frame.size.height) * CGFloat(view.tag - 1))
                }
                //move to next alert
                counter -= 1
            }
        }
        
        //create and add new alert
        alertView.view.frame = CGRect(x: self.view.frame.size.width - alertView.view.frame.size.width - 25,
                                      y: self.view.frame.origin.y + self.topBarView.frame.size.height + topPadding,
                                       width: alertView.view.frame.size.width,
                                       height: alertView.view.frame.size.height)
        alertView.alertText.text = text
        alertView.alertText.backgroundColor = color
        alertView.view.alpha = 0.75
        alertView.view.tag = 1
        alertView.view.isUserInteractionEnabled = true
        self.view.addSubview(alertView.view)
        alertViewsShowing += 1
        
        //add tap gesture recogniazer to subView to remove subview on tap
        let aSelector : Selector = #selector(removeSubview)
        let tapGesture = UITapGestureRecognizer(target:self, action: aSelector)
        alertView.view.addGestureRecognizer(tapGesture)
        
        //timer to automatically remove alert after set amount of time
        //Timer.scheduledTimer(timeInterval: TimeInterval(5.0), target: self, selector: #selector(self.removeSubview), userInfo: nil, repeats: false)
    }
    
    @objc func removeSubview(_ sender: UITapGestureRecognizer? = nil) {
        //unwrap tag from sender view
        if let tag = sender?.view?.tag {
            //find view with matching tag
            if let viewWithTag = self.view.viewWithTag(tag) {
                //remove from superview
                viewWithTag.removeFromSuperview()
                alertViewsShowing -= 1
            }
            //move other alert subviews up if they are at a lower position then the removed subview
            if tag < alertViewsShowing + 1 {
                for view in view.subviews {
                    //move up in order by reducing tag by 1 if the alert was displayed below the removed alert
                    if view.tag > tag {
                        view.tag -= 1
                        //edit transformation with changes
                        UIView.animate(withDuration: 0.2) {
                            view.transform = CGAffineTransform( translationX: 0.0, y: CGFloat(70) * CGFloat(view.tag - 1))
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - DJI SDK Manager Delegate Methods
    //check registration status
    func appRegisteredWithError(_ error: Error?) {
        if let error = error {
            showAlert(on: self, title: "Registration Error", message: error.localizedDescription)
            showAlertSubView(with: "Registration Error", color: UIColor(rgb: 0xc0392b))
        } else {
            showAlertSubView(with: "App Registration Success", color: UIColor(rgb: 0x27ae60))
            //connect to drone
            DJISDKManager.startConnectionToProduct()
            //option to connect via bridge app
            /*if connectViaBridge {
                DJISDKManager.enableBridgeMode(withBridgeAppIP: bridgeAppIP)
            } else {
                DJISDKManager.startConnectionToProduct()
            }*/
        }
    }
    //product connectivity changes
    func productConnected(_ product: DJIBaseProduct?) {
        if let _ = product, let flightController = fetchFlightController() {
            flightController.delegate = self
        } else {
            showAlertSubView(with: "Flight controller disconnected", color: UIColor(rgb: 0xc0392b))
        }
    }
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        //Not used
    }
    
    //MARK:  DJIFlightControllerDelegate
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        droneLocation = state.aircraftLocation?.coordinate
        
        //check if home location has changed, if so update on map
        if homeLocation?.latitude != state.homeLocation?.coordinate.latitude || homeLocation?.longitude != state.homeLocation?.coordinate.longitude{
            homeLocation = state.homeLocation?.coordinate
            if let homeLocationUnwrapped = state.homeLocation?.coordinate {
                self.mapController?.updateHome(location: homeLocationUnwrapped, with: mapView)
                showAlertSubView(with: "Home Point Updated", color: UIColor(rgb: 0x27ae60))
            }
        }
        
        modeLabel.text = state.flightModeString
        gpsLabel.text = String(state.satelliteCount)
        vsLabel.text = String(format: "%0.1f M/S", state.velocityZ) //round decimal to one place
        hsLabel.text = String(format: "%0.1f M/S", sqrt(pow(state.velocityX,2) + pow(state.velocityY,2)))
        altitudeLabel.text = String(format: "%0.1f M", state.altitude)
        
        if let droneLocation = droneLocation {
            self.mapController?.updateAircraft(location: droneLocation, with: mapView)
        }
        
        let radianYaw = state.attitude.yaw.degreesToRadians
        self.mapController?.updateAircraftHeading(heading: Float(radianYaw))
    }
    
    //MARK: Custom Methods
    @objc func addWaypoints(tapGesture: UITapGestureRecognizer) {
        let point = tapGesture.location(in: mapView)
        if tapGesture.state == UIGestureRecognizer.State.ended {
            if isEditingPoints {
                mapController?.add(point: point, for: self.mapView)
            }
        }
    }
    
    //MARK:  MKMapViewDelegate Method
    //create a view for given annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKPointAnnotation.self) {
            if annotation.subtitle == "Home Point" {
                let homePinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Home_Annotation")
                homePinView.image = UIImage(named: "home")
                return homePinView
            } else {
                let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin_Annotation")
                pinView.pinTintColor = UIColor.purple
                return pinView
            }
        } else if annotation.isKind(of: AircraftAnnotation.self) {
            //set the annotation's annotationView to a AircraftAnnotationView Class type object if it's an AircraftAnnotation
            let annotationView = AircraftAnnotationView(annotation: annotation, reuseIdentifier: "Aircraft_Annotation")
            (annotation as? AircraftAnnotation)?.annotationView = annotationView
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self) {
            // draw the track
            let polyLine = overlay
            let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)
            polyLineRenderer.strokeColor = UIColor.blue
            polyLineRenderer.lineWidth = 2.0
            return polyLineRenderer
        }
        return MKPolylineRenderer()
    }
    
    //MARK:  CLLocation Methods
    func startUpdateLocation() {
        if CLLocationManager.locationServicesEnabled() {
            if self.locationManager == nil {
                self.locationManager = CLLocationManager()
                self.locationManager?.delegate = self
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager?.distanceFilter = 0.1
                self.locationManager?.requestAlwaysAuthorization()
                self.locationManager?.startUpdatingLocation()
            }
        } else {
            showAlertSubView(with: "Location Service is not available", color: UIColor(rgb: 0xc0392b))
        }
    }
    
    //MARK:  - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = locations.last?.coordinate
    }
    
    //MARK: - DJIGSButtonController Delegate Methods
    func stopBtnActionIn(gsBtnVC: DJIGSButtonController) {
        self.missionOperator()?.stopMission(completion: { (error:Error?) in
            if let error = error {
                showAlert(on: self, title: "Stop Mission Failed", message: error.localizedDescription)
                self.showAlertSubView(with: "Stop Mission Failed", color: UIColor(rgb: 0xc0392b))
            } else {
                self.showAlertSubView(with: "Mission Stopped Sucessfully", color: UIColor(rgb: 0x27ae60))
            }
        })
    }

    func clearBtnActionIn(gsBtnVC: DJIGSButtonController) {
        self.mapController?.cleanAllPoints(with: self.mapView)
    }

    func focusMapBtnActionIn(gsBtnVC: DJIGSButtonController) {
        self.focusMap()
    }
    
    func startBtnActionIn(gsBtnVC: DJIGSButtonController) {
        self.missionOperator()?.startMission(completion: { (error:Error?) in
            if let error = error {
                showAlert(on: self, title: "Start Mission Failed:", message: error.localizedDescription)
                self.showAlertSubView(with: "Start Mission Failed", color: UIColor(rgb: 0xc0392b))
            } else {
                self.showAlertSubView(with: "Mission Started Sucessfully", color: UIColor(rgb: 0x27ae60))
            }
        })
    }

    func add(button: UIButton, actionIn gsBtnVC: DJIGSButtonController) {
        if self.isEditingPoints {
            self.isEditingPoints = false
            button.setTitle("Add", for: UIControl.State.normal)
        } else {
            self.isEditingPoints = true
            button.setTitle("Finished", for: UIControl.State.normal)
        }
    }
    
    func configBtnActionIn(gsBtnVC: DJIGSButtonController) {
        //create array, check if it exists or is empty
        guard let wayPoints = self.mapController?.editPoints else {
            self.showAlertSubView(with: "No waypoints", color: UIColor(rgb: 0xc0392b))
            return
        }
        if wayPoints.count < 2 {
            self.showAlertSubView(with: "Not enough waypoints for mission", color: UIColor(rgb: 0xc0392b))
            return
        }
        //would also need to check GPS status > 6 satellites
        
        UIView.animate(withDuration: 0.25) { [weak self] () in
            self?.waypointConfigVC?.view.alpha = 1.0
            self?.indWaypointConfigVC?.view.alpha = 0
        }
        
        self.waypointMission?.removeAllWaypoints()
        
        if self.waypointMission == nil {
            self.waypointMission = DJIMutableWaypointMission()
            self.waypointMission?.rotateGimbalPitch = true
        }
        
        for location in wayPoints {
            if CLLocationCoordinate2DIsValid(location.coordinate) {
                self.waypointMission?.add(DJIWaypoint(coordinate: location.coordinate))
            }
        }
        
    }
    
    func switchTo(mode: GSViewMode, inGSBtnVC: DJIGSButtonController) {
        focusMap()
    }

    //MARK: - DJIWaypointConfigViewController Delegate Methods
    func missionOperator() -> DJIWaypointMissionOperator? {
        return DJISDKManager.missionControl()?.waypointMissionOperator()
    }
    
    func cancelBtnActionInDJIWaypointConfigViewController(viewController: DJIWaypointConfigViewController) {
        UIView.animate(withDuration: 0.25) { [weak self] () in
            self?.waypointConfigVC?.view.alpha = 0
        }
    }
    
    //option to edit waypoint values individually instead of a route
    func editIndividuallyBtnActionInDJIWaypointConfigViewController(viewController: DJIWaypointConfigViewController) {
        //assign default altitude values from route to individual waypoints
        if let waypointMission = self.waypointMission, let waypointConfigVC = self.waypointConfigVC {
            for waypoint in waypointMission.allWaypoints() {
                //check if default altitude values have been assigned from the route by seeing if text field has already been hidden
                if waypointConfigVC.altitudeTextField.isHidden == false {
                    if let altitudeString = waypointConfigVC.altitudeTextField.text {
                        if let altitude = Float(altitudeString){
                            waypoint.altitude = altitude
                        } else{
                            showAlertSubView(with: "Current altitude input not valid", color: UIColor(rgb: 0xc0392b))
                            return
                        }
                    }
                }
            }
            //fill text fields with current values
            indWaypointConfigVC?.altitudeTextField.text = String(waypointMission.allWaypoints()[currentIndividualWaypointEditing].altitude)
            indWaypointConfigVC?.gimbalPitchTextField.text = String(waypointMission.allWaypoints()[currentIndividualWaypointEditing].gimbalPitch)
        }
        
        //swap visibility of waypoint view from editing enitre route to individual
        UIView.animate(withDuration: 0.25) { [weak self] () in
            self?.waypointConfigVC?.view.alpha = 0
            self?.indWaypointConfigVC?.view.alpha = 1
        }
        
        waypointConfigVC?.altitudeTextField.isHidden = true
        
    }
    
    func editRouteBtnActionInDJIWaypointConfigViewController(viewController: DJIWaypointConfigViewController) {
        waypointConfigVC?.altitudeTextField.isHidden = false
    }

    func finishBtnActionInDJIWaypointConfigViewController(viewController: DJIWaypointConfigViewController) {
        
        UIView.animate(withDuration: 0.25) { [weak self] () in
            self?.waypointConfigVC?.view.alpha = 0
        }
        
        //if altitude text field is visible know altitude was edited by route instead of individually
        if waypointConfigVC?.altitudeTextField.isHidden == false {
            if let waypointMission = self.waypointMission, let waypointConfigVC = self.waypointConfigVC {
                for waypoint in waypointMission.allWaypoints() {
                    if let altitudeString = waypointConfigVC.altitudeTextField.text {
                        if let altitude = Float(altitudeString){
                            waypoint.altitude = altitude
                        } else{
                            showAlertSubView(with: "Current altitude input not valid", color: UIColor(rgb: 0xc0392b))
                            return
                        }
                    }
                }
            }
        }

        if let waypointConfigVC = self.waypointConfigVC {
            self.waypointMission?.maxFlightSpeed = ((self.waypointConfigVC?.maxFlightSpeedTextField.text ?? "0.0") as NSString).floatValue
            self.waypointMission?.autoFlightSpeed = ((self.waypointConfigVC?.autoFlightSpeedTextField.text ?? "0.0") as NSString).floatValue
            let selectedHeadingIndex = waypointConfigVC.headingSegmentedControl.selectedSegmentIndex
            self.waypointMission?.headingMode = DJIWaypointMissionHeadingMode(rawValue:UInt(selectedHeadingIndex)) ?? DJIWaypointMissionHeadingMode.auto
            let selectedActionIndex = waypointConfigVC.actionSegmentedControl.selectedSegmentIndex
            self.waypointMission?.finishedAction = DJIWaypointMissionFinishedAction(rawValue: UInt8(selectedActionIndex)) ?? DJIWaypointMissionFinishedAction.noAction
        }
        
        if let waypointMission = self.waypointMission {
            self.missionOperator()?.load(waypointMission)
            self.missionOperator()?.addListener(toFinished: self, with: DispatchQueue.main, andBlock: { [weak self] (error: Error?) in
                if let error = error {
                    if let vc = self {
                        showAlert(on: vc, title: "Mission Execution Failed", message: error.localizedDescription)
                        vc.showAlertSubView(with: "Mission Execution Failed", color: UIColor(rgb: 0xc0392b))
                    }
                } else {
                    if let vc = self {
                        vc.showAlertSubView(with: "Mission Execution Finished", color: UIColor(rgb: 0x27ae60))
                    }
                }
            })
        }
        
        self.missionOperator()?.uploadMission(completion: { (error:Error?) in
            if let error = error {
                showAlert(on: self, title: "Upload Mission Failed", message: error.localizedDescription)
                self.showAlertSubView(with: "Upload Mission Failed", color: UIColor(rgb: 0xc0392b))
                
            } else {
                self.showAlertSubView(with: "Upload Mission Finished", color: UIColor(rgb: 0x27ae60))
            }
        })
    }
    
    //MARK: - IndividualWaypointConfigViewController Delegate Methods
    
    func extendGimbalPitch(viewController: IndividualWaypointConfigViewController) {
        if let gimbalArray = fetchGimbal() {
            let gimbal = gimbalArray[0]
            gimbal.delegate = self
            //check if pitch extension is a supported option, if so enable
            if let gimbalAbility = gimbal.capabilities[DJIGimbalParamPitchRangeExtensionEnabled] as? DJIParamCapability {
                if gimbalAbility.isSupported {
                    gimbal.setPitchRangeExtensionEnabled(true) { error in
                        if error != nil {
                            self.showAlertSubView(with: "Unable to Set Gimbal Pitch Extension", color: UIColor(rgb: 0xf1c40f))
                        } else {
                            self.gimbalPitchMax = 30
                            self.indWaypointConfigVC?.gimbalPitchLabel.text = "Gimbal Pitch (\(self.gimbalPitchMin) to \(self.gimbalPitchMax))"
                        }
                    }
                }
            }
            //set gimbal pitch to 0
            let gimbalRotation = DJIGimbalRotation(pitchValue: 0, rollValue: nil, yawValue: nil, time: 1, mode: DJIGimbalRotationMode.absoluteAngle, ignore: true)
            gimbal.rotate(with: gimbalRotation) { error in
                if error != nil {
                    self.showAlertSubView(with: "Unable to Set Gimbal Pitch to 0 degrees", color: UIColor(rgb: 0xf1c40f))
                }
            }
        } else {
            showAlertSubView(with: "Unable to Set Gimbal Pitch Extension", color: UIColor(rgb: 0xc0392b))
        }
    }
    
    func updateIndividualWaypointValue() -> Bool {
        if let altitudeString = indWaypointConfigVC?.altitudeTextField.text {
            if let altitude = Float(altitudeString) {
                waypointMission?.allWaypoints()[currentIndividualWaypointEditing].altitude = altitude
            } else{
                showAlertSubView(with: "Current altitude input not valid", color: UIColor(rgb: 0xc0392b))
                return false
            }
        } else{
            showAlertSubView(with: "Current altitude input not valid", color: UIColor(rgb: 0xc0392b))
            return false
        }
        
        if let gimbalPitchString = indWaypointConfigVC?.gimbalPitchTextField.text {
            if let gimbalPitch = Float(gimbalPitchString) {
                if gimbalPitch != waypointMission?.allWaypoints()[currentIndividualWaypointEditing].gimbalPitch {
                    if gimbalPitch <= Float(gimbalPitchMax) && gimbalPitch >= Float(gimbalPitchMin) {
                        waypointMission?.allWaypoints()[currentIndividualWaypointEditing].gimbalPitch = gimbalPitch
                    }else{
                        showAlertSubView(with: "Current gimbal pitch is not between \(gimbalPitchMax) & \(gimbalPitchMin)", color: UIColor(rgb: 0xc0392b))
                        return false
                    }
                }
            } else{
                showAlertSubView(with: "Current gimbal pitch input not valid", color: UIColor(rgb: 0xc0392b))
                return false
            }
        } else{
            showAlertSubView(with: "Current gimbal pitch input not valid", color: UIColor(rgb: 0xc0392b))
            return false
        }
        return true
    }

    func previousWaypointBtnActionInIndividualWaypointConfigViewController(viewController: IndividualWaypointConfigViewController) {
        if updateIndividualWaypointValue() {
            currentIndividualWaypointEditing -= 1
            if currentIndividualWaypointEditing < 0 {
                currentIndividualWaypointEditing = (waypointMission?.allWaypoints().count ?? 0) - 1
            }
            indWaypointConfigVC?.currentWaypointLabel.text = "Waypoint \(currentIndividualWaypointEditing + 1)"
            
            if let waypointMission = waypointMission {
                indWaypointConfigVC?.altitudeTextField.text = String(waypointMission.allWaypoints()[currentIndividualWaypointEditing].altitude)
                indWaypointConfigVC?.gimbalPitchTextField.text = String(waypointMission.allWaypoints()[currentIndividualWaypointEditing].gimbalPitch)
            }
        }
    }
    
    func nextWaypointBtnActionInIndividualWaypointConfigViewController(viewController: IndividualWaypointConfigViewController) {
        if updateIndividualWaypointValue() {
            currentIndividualWaypointEditing += 1
            if currentIndividualWaypointEditing == (waypointMission?.allWaypoints().count ?? 0) {
                currentIndividualWaypointEditing = 0
            }
            indWaypointConfigVC?.currentWaypointLabel.text = "Waypoint \(currentIndividualWaypointEditing + 1)"
            
            if let waypointMission = waypointMission {
                indWaypointConfigVC?.altitudeTextField.text = String(waypointMission.allWaypoints()[currentIndividualWaypointEditing].altitude)
                indWaypointConfigVC?.gimbalPitchTextField.text = String(waypointMission.allWaypoints()[currentIndividualWaypointEditing].gimbalPitch)
            }
        }
    }
    
    func doneEditingIndivWaypointBtnActionInIndividualWaypointConfigViewController(viewController: IndividualWaypointConfigViewController) {
        if updateIndividualWaypointValue() {
            UIView.animate(withDuration: 0.25) { [weak self] () in
                self?.waypointConfigVC?.view.alpha = 1
                self?.indWaypointConfigVC?.view.alpha = 0
            }
            indWaypointConfigVC?.currentWaypointLabel.text = "Waypoint 1"
            currentIndividualWaypointEditing = 0
        }
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")
       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
