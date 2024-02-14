//
//  ViewController.swift
//  Maps
//
//  Created by Inderpreet Singh on 10/02/24.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    // Call Model
    var mapsModelObject = MapsModel()
    
    // map View
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    // Location Info View
    @IBOutlet weak var locationDetailView: UIView!
    @IBOutlet weak var distanceETALable: UILabel!
    @IBOutlet weak var startNavigationButton: UIButton!
    @IBOutlet weak var cancleButton: UIButton!
    
    let locationManager = CLLocationManager()
    var fromLocationCoordinate: CLLocationCoordinate2D?
    var toLocationCoordinate: CLLocationCoordinate2D?
    
    // Suggestions
    var suggestionsView = UIView()
    var suggestionsTableView = UITableView()
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var searchResult: [MKMapItem] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setLocationManager()
        setMapView()
        textFieldSet()
        setupStartButton()
        setupLocationDetails()
        
        // TO-Do add to func
        suggestionsView.alpha = 0
        suggestionsTableView.alpha = 0
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
    
    func setupSuggestionsSearch(){
        searchCompleter.delegate = self
    }
    
    func setAnnotation(location:CLLocation , title : String){
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = location.coordinate
        self.mapView.addAnnotation(annotation)
        let view = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        self.mapView.setRegion(view, animated: true)
    }
    
    func setETA() {
        let distance = mapsModelObject.getDistance(from: fromLocationCoordinate!, to: toLocationCoordinate!)
        mapsModelObject.getEstimatedTimeOfArrival(sourceCoordinate: fromLocationCoordinate!, destinationCoordinate: toLocationCoordinate!) { eta, error,unit  in
            if let eta = eta {
                self.distanceETALable.text = "\(eta) \(unit!) ( \(distance))"
            } else if let error = error {
                self.distanceETALable.text = "Error calculating ETA: \(error.localizedDescription) (\(distance))"
            }
        }
    }
    
    func showNavigation(){
        if let fromCoordinate = self.fromLocationCoordinate {
            if let toCoordinate = self.toLocationCoordinate {
                self.drawRoute(from: fromCoordinate, to: toCoordinate)
                self.setAnnotation(location: CLLocation(latitude: fromCoordinate.latitude, longitude: fromCoordinate.longitude), title: self.addressTextField.text ?? "")
            
                self.setAnnotation(location: CLLocation(latitude: toCoordinate.latitude, longitude: toCoordinate.longitude), title: self.toTextField.text ?? "")
                
                print ("from \(self.fromLocationCoordinate!)")
                print ("to \(toLocationCoordinate!)")
            }
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
    
    @IBAction func startButtonAction(_ sender: Any) {
        // Start Location
        mapsModelObject.getLocationFromAddress(address: addressTextField.text ?? "") { isSucceeded, placemarks, error in
            if isSucceeded == true {
                self.fromLocationCoordinate = placemarks
                print(placemarks!)
                // HACKKKK
                self.mapsModelObject.getLocationFromAddress(address: self.toTextField.text ?? "") { isSucceeded, placemarks, error in
                    if isSucceeded == true {
                        self.toLocationCoordinate = placemarks
                        print(placemarks!)
                        self.showNavigation()
                    }
                }
            } else {
                self.alertUser(title: "Error While Searching Location", message: error ?? "")
            }
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
            self.distanceETALable.text = "Loading ...!"
            
        })
    }
    
    func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okay = UIAlertAction(title: "Okay", style: .default)
        
        alert.addAction(okay)
        self.present(alert, animated: true)
        
    }

    func setupSuggestionsView(cgrect:CGRect){
        suggestionsView.frame = cgrect
        suggestionsTableView.frame = CGRectMake(0, 0, suggestionsView.frame.width, suggestionsView.frame.height)
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self
        suggestionsTableView.register(UINib.init(nibName: "SuggestionTableViewCell", bundle: nil), forCellReuseIdentifier: "Suggestions")
        suggestionsView.addSubview(suggestionsTableView)
        // Animate View while adding
        UIView.animate(withDuration: 0.5, animations: {
            self.suggestionsView.alpha = 1
            self.suggestionsTableView.alpha = 1

        })
        view.addSubview(suggestionsView)
    }
    
    func performLocalSearch(query: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                if let error = error {
                    print("Local search error: \(error.localizedDescription)")
                }
                return
            }
            
            // Handle search results
            self.handleSearchResults(response.mapItems)
        }
    }
    
    func handleSearchResults(_ mapItems: [MKMapItem]) {
        // Update the search results array
        searchResult = mapItems
        
        // Reload the table view
        DispatchQueue.main.async {
            self.suggestionsTableView.reloadData()
        }
    }
}

extension ViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        searchCompleter.queryFragment = textField.text!
        let cgrect = CGRect(x: textField.frame.origin.x, y: textField.frame.origin.y + textField.frame.height, width: textField.frame.width, height: 200)
        setupSuggestionsView(cgrect: cgrect)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else { return true }
        performLocalSearch(query: text)
        return true
    }
    
}

extension ViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        suggestionsTableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mapItem = searchResult[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Suggestions", for: indexPath) as? SuggestionTableViewCell else { return UITableViewCell()}
        
        cell.setupCellView(title: mapItem.name!, detail: mapItem.placemark.title!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // hide Suggestion View
        UIView.animate(withDuration: 0.5, animations: {
            self.suggestionsView.alpha = 0
            self.suggestionsTableView.alpha = 0
        })
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

