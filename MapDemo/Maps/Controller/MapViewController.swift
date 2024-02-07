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
    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocationManager()
        textFields()
        mapView.delegate = self
        mapView.mapType = .standard
        switchButton.isOn = true
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
    
    @objc func setColour(){
        if switchButton.isOn{
            mapView.backgroundColor = .black
        } else {
            mapView.backgroundColor = .white
        }
    }
    
    func setLocationManager(){
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 20
        locationManager.desiredAccuracy = 100
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setAnnotation(location:CLLocation , title : String){
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = location.coordinate
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        
        let view = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        self.mapView.setRegion(view, animated: true)
    }
    
    func getLocation(address:String){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { placemarks, error in
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
            
            self.setAnnotation(location: location , title: "Title")
            
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
            getLocation(address: address)
        }
        addressTextField.resignFirstResponder()
        searchButton.isSelected = true
    }
    
    @IBAction func switchButtonAction(_ sender: Any) {
        if switchButton.isOn{
            self.overrideUserInterfaceStyle = .light
        } else {
            self.overrideUserInterfaceStyle = .dark
        }
        
    }
    
    @IBAction func goButtonAction(_ sender: Any) {
        if let fromAddress = addressTextField.text{
            getLocation(address: fromAddress)
            
        }
        
        if  let toAddress = toTextField.text  {
            self.getLocation(address: toAddress)
        }
        
    }
}
extension MapViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension MapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _ = locations.first
        
    }
    
}
extension MapViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        return renderer
    }
    
//    func drawRoute(from startCoordinate: CLLocationCoordinate2D, to endCoordinate: CLLocationCoordinate2D) {
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
//        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endCoordinate))
//        request.transportType = .automobile
//        
//        let directions = MKDirections(request: request)
//        directions.calculate { [weak self] response, error in
//            guard let self = self else { return }
//            guard let route = response?.routes.first else {
//                // Handle error or show alert if route not found
//                return
//            }
//            
//            // Remove existing overlays (if any)
//            self.mapView.removeOverlays(self.mapView.overlays)
//            
//            // Add route to map
//            self.mapView.addOverlay(route.polyline)
//            
//            // Optionally, zoom to fit the route
//            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
//        }
//    }
}

