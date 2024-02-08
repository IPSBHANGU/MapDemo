//
//  ViewController.swift
//  MapDemo
//
//  Created by Umang Kedan on 02/02/24.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var switchButton: UISwitch!
    
    @IBOutlet weak var cutButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var fromLocationCoordinate: CLLocationCoordinate2D?
    var toLocationCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocationManager()
        textFields()
        cutButton.isHidden = true
        goButton.layer.borderWidth = 1
        mapView.delegate = self
        mapView.mapType = .standard
        switchButton.isOn = false
        segmentController.addTarget(self, action: #selector(segmentValueChanged(sender: )), for: .valueChanged)
        
    }
    
    func textFields(){
        addressTextField.delegate = self
        addressTextField.becomeFirstResponder()
        addressTextField.layer.borderWidth = 0.5
        addressTextField.layer.cornerRadius = 10
        
        toTextField.delegate = self
        toTextField.layer.borderWidth = 0.5
        toTextField.layer.cornerRadius = 10
    }
    
    @objc func segmentValueChanged(sender : UISegmentedControl){
        segmentController.setTitle("Standard", forSegmentAt: 0)
        segmentController.setTitle("Satellite", forSegmentAt: 1)
        
        switch sender.selectedSegmentIndex {
        case 0 : mapView.mapType = .standard
        case 1 : mapView.mapType = .satellite
        default : mapView.mapType = .standard
        }
    }
    
    func setLocationManager(){
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 20
        locationManager.desiredAccuracy = 100
        mapView.showsUserLocation = true
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setAnnotation(location:CLLocation , title : String){
        
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = location.coordinate
        
        self.mapView.addAnnotation(annotation)
        
        let view = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        self.mapView.setRegion(view, animated: true)
    }
    
    func getLocation(address:String , isFormAddress : Bool){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let error = error {
                print("Geocode failed with error: \(error.localizedDescription)")
                return
            }
            
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location else {
                print("No location found for the given address")
                return
            }
            
            print("Location found: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            if isFormAddress {
                self.fromLocationCoordinate = location.coordinate
            } else {
                self.toLocationCoordinate = location.coordinate
            }
            
            if let fromCoordinate = self.fromLocationCoordinate,
               let toCoordinate = self.toLocationCoordinate {
                self.drawRoute(from: fromCoordinate, to: toCoordinate)
                self.setAnnotation(location: CLLocation(latitude: fromCoordinate.latitude, longitude: fromCoordinate.longitude), title: addressTextField.text ?? "")
            
                self.setAnnotation(location: CLLocation(latitude: toCoordinate.latitude, longitude: toCoordinate.longitude), title: toTextField.text ?? "")
            }
        }
    }
    
    func getAddress(location : CLLocation){
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: {placemark,error in
            print(placemark?.first ?? "")
            print(placemark?.count ?? "")
            if placemark != nil {
                
            }
        })
    }
    
    @IBAction func currentLocationAction(_ sender: Any) {
        if let location = locationManager.location{
            searchButton.isSelected = false
            setAnnotation(location: location , title: "Current Location")
            getAddress(location: location)

        }
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        if let address = addressTextField.text {
            getLocation(address: address , isFormAddress: true)
        }
        addressTextField.resignFirstResponder()
        searchButton.isSelected = true
    }
    
    @IBAction func switchButtonAction(_ sender: Any) {
        if switchButton.isOn{
            self.overrideUserInterfaceStyle = .dark
        } else {
            self.overrideUserInterfaceStyle = .light
        }
    }
    
    @IBAction func goButtonAction(_ sender: Any) {
        
        if let fromAddress = addressTextField.text{
            print("From cooordinates")
            getLocation(address: fromAddress , isFormAddress: true)
            addressTextField.isHidden = true
            
        }
        
        if let toAddress = toTextField.text  {
            print("to coordinates")
            self.getLocation(address: toAddress , isFormAddress: false)
            toTextField.isHidden = true
        }
        
        switchButton.isHidden = true
        locateButton.isHidden = true
        cutButton.isHidden = false
        goButton.isHidden = true
        
    }
    
    @IBAction func cutButtonAction(_ sender: Any) {
        switchButton.isHidden = false
        locateButton.isHidden = false
        goButton.isHidden = false
        addressTextField.isHidden = false
        toTextField.isHidden = false
        cutButton.isHidden = true
        resetMap()
    }
    
}

extension MapViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension MapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let coordinates = locations.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        mapView.addOverlay(polyline)
    }
}

extension MapViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 3
            return renderer

        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.markerTintColor = .systemBlue
        return annotationView
    }

    func drawRoute(from startCoordinate: CLLocationCoordinate2D, to endCoordinate: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endCoordinate))
        request.transportType = .any
        
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: { response , error  in
            guard let route = response?.routes.first else {
                return
            }
            self.mapView.removeOverlays(self.mapView.overlays)  // Remove existing overlays
            
            self.mapView.addOverlay(route.polyline)
        })
    }
    
    func resetMap(){
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        mapView.mapType = .standard
        addressTextField.text = ""
        toTextField.text = ""
    }
    
}
//    func drawRouteBetweenAnnotations() {
//        guard let annotations = mapView.annotations as? [MKPointAnnotation],
//                annotations.count >= 2 else {
//            print("At least two annotations are required to draw a route")
//            return
//        }
//        
//        let coordinates = annotations.map { $0.coordinate } //Creates an array coordinates by extracting the coordinate property from each annotation.
//        
//        // Remove any existing overlays
//        mapView.removeOverlays(mapView.overlays)
//        
//        // Iterate through coordinates and draw route between them
////        for i in 0..<coordinates.count - 1 {
////            print("i = " , i)
////            let polyline = MKPolyline(coordinates: [coordinates[i] , coordinates[i+1]], count: 2)
////            mapView.addOverlay(polyline)
////        }
//        
//        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
//        mapView.addOverlay(polyline)
//        
////        var i = 0
////        for var i in i..<coordinates.count - 1{
////            let polyline = MKPolyline(coordinates: coordinates, count: 2)
////            mapView.addOverlay(polyline)
////            i = i+1
////        }
//    }
//}

