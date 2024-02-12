//
//  ViewController.swift
//  Maps
//
//  Created by Inderpreet Singh on 10/02/24.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {

    // map View
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    // Location Info View
    @IBOutlet weak var locationDetailView: UIView!
    @IBOutlet weak var distanceETALable: UILabel!
    @IBOutlet weak var startNavigationButton: UIButton!
    
    let locationManager = CLLocationManager()
    var fromLocationCoordinate: CLLocationCoordinate2D?
    var toLocationCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setLocationManager()
        setMapView()
        textFieldSet()
        setupStartButton()
        setupLocationDetails()
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
    
    func setMapView() {
        mapView.delegate = self
    }
    
    func textFieldSet(){
        addressTextField.delegate = self
        toTextField.delegate = self
        
        // make textField round
        addressTextField.layer.cornerRadius = 9
        toTextField.layer.cornerRadius = 9
        
        // translucent textField
        addressTextField.backgroundColor = UIColor(white: 1.1, alpha: 0.5)
        toTextField.backgroundColor = UIColor(white: 1.1, alpha: 0.5)
    }
    
    func setupStartButton(){
        startButton.backgroundColor = UIColor(white: 1.1, alpha: 0.5)
        startButton.layer.cornerRadius = 20
    }
    
    func setupLocationDetails(){
        locationDetailView.layer.cornerRadius = 20
        // hide View by-default
        locationDetailView.alpha = 0
        // change background color
        locationDetailView.backgroundColor = .white
        startNavigationButton.backgroundColor = UIColor(red: 0.5, green: 2.2, blue: 0.5, alpha: 2.0)
        startNavigationButton.layer.cornerRadius = 20
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
                print(fromLocationCoordinate)
            } else {
                self.toLocationCoordinate = location.coordinate
                print(toLocationCoordinate)
            }
            
            if let fromCoordinate = self.fromLocationCoordinate,
               let toCoordinate = self.toLocationCoordinate {
                self.drawRoute(from: fromCoordinate, to: toCoordinate)
                self.setAnnotation(location: CLLocation(latitude: fromCoordinate.latitude, longitude: fromCoordinate.longitude), title: addressTextField.text ?? "")
            
                self.setAnnotation(location: CLLocation(latitude: toCoordinate.latitude, longitude: toCoordinate.longitude), title: toTextField.text ?? "")
                
                print ("from \(fromLocationCoordinate!)")
                print ("to \(toLocationCoordinate!)")
            }
        }
    }
    
    func calculateDistance(from sourceCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D) -> String {
            let sourceLocation = CLLocation(latitude: sourceCoordinate.latitude, longitude: sourceCoordinate.longitude)
            let destinationLocation = CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
            
        let distanceInKilometers = sourceLocation.distance(from: destinationLocation) / 1000.0
        let formattedDistance = String(format: "%.2f km", distanceInKilometers)
            return formattedDistance
        }
    
    func getEstimatedTimeOfArrival(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, completion: @escaping (Int?, Error?) -> Void) {
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let request = MKDirections.Request()
        request.source = sourceItem
        request.destination = destinationItem
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        request.departureDate = Date()
        
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let route = response?.routes.first else {
                let error = NSError(domain: "Maps", code: 0, userInfo: [NSLocalizedDescriptionKey: "No route found"])
                completion(nil, error)
                return
            }
            
            let etaInSeconds = route.expectedTravelTime
            let etaInMinutes = Int(etaInSeconds / 60)
            
            completion(etaInMinutes, nil)
        }
    }
    
    func setETA() {
        let distance = calculateDistance(from: fromLocationCoordinate!, to: toLocationCoordinate!)
        
        getEstimatedTimeOfArrival(sourceCoordinate: fromLocationCoordinate!, destinationCoordinate: toLocationCoordinate!) { etaInMinutes, error in
            if let etaInMinutes = etaInMinutes {
                self.distanceETALable.text = "\(etaInMinutes) minutes( \(distance))"
            } else if let error = error {
                self.distanceETALable.text = "Error calculating ETA: \(error.localizedDescription) (\(distance))"
            }
        }
    }
    
    @IBAction func startButtonAction(_ sender: Any) {
        Task { @MainActor in
            if let fromAddress = addressTextField.text{
                print("From cooordinates")
                getLocation(address: fromAddress , isFormAddress: true)
                
            }
            
            if let toAddress = toTextField.text  {
                print("to coordinates")
                self.getLocation(address: toAddress , isFormAddress: false)
            }
            
            // animate View When Start Button is triggered
            UIView.animate(withDuration: 0.5, animations: {
                self.locationDetailView.alpha = 1
            })
            
            UIView.animate(withDuration: 0.5, animations: {
                self.addressTextField.alpha = 0
                self.toTextField.alpha = 0
                self.startButton.alpha = 0
            })
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        // Bring back Text Fields and Start Button
        UIView.animate(withDuration: 0.5, animations: {
            self.addressTextField.alpha = 1
            self.toTextField.alpha = 1
            self.startButton.alpha = 1
            // hide View
            self.locationDetailView.alpha = 0
        })
    }
}

extension ViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension ViewController:CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Access granted")
            locationManager.startUpdatingLocation()
        case .denied:
            print("Access not allowed")
        case .notDetermined:
            print("Access Not determined")
        case .restricted:
            print("Limited access")
        default:
            print("Default case")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let coordinates = locations.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        mapView.addOverlay(polyline)
    }
}

extension ViewController : MKMapViewDelegate{
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
            self.setETA()
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

