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
    @IBOutlet weak var addressSearchBar: UISearchBar!
    @IBOutlet weak var toSearchBar: UISearchBar!
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
    var closeSuggestions = UIButton()
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var activeSearchBar:UISearchBar?
    
    // Current Location
    var currentLocation = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setLocationManager()
        setMapView()
        searchBarSet()
        setupStartButton()
        setupLocationDetails()
        setupSuggestionsView()
        setupCurrentLocationButton()
        searchCompleter.delegate = self
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
    
    func searchBarSet(){
        addressSearchBar.delegate = self
        toSearchBar.delegate = self
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
                
                self.setAnnotation(location: CLLocation(latitude: fromCoordinate.latitude, longitude: fromCoordinate.longitude), title: self.addressSearchBar.text ?? "")
            
                self.setAnnotation(location: CLLocation(latitude: toCoordinate.latitude, longitude: toCoordinate.longitude), title: self.toSearchBar.text ?? "")
                
                print ("from \(self.fromLocationCoordinate!)")
                print ("to \(toLocationCoordinate!)")
            }
        }

        // animate View When Start Button is triggered
        UIView.animate(withDuration: 0.5, animations: {
            self.locationDetailView.alpha = 1
            self.currentLocation.frame = CGRect(x: 348, y: 600, width: 50, height: 50)
        })
        
        UIView.animate(withDuration: 0.5, animations: {
            self.addressSearchBar.alpha = 0
            self.toSearchBar.alpha = 0
            self.startButton.alpha = 0
        })
    }
    
    func setupCurrentLocationButton(){
        currentLocation.alpha = 1
        self.currentLocation.frame = CGRect(x: 348, y: 728, width: 50, height: 50)
        currentLocation.layer.cornerRadius = 20
        currentLocation.setImage(UIImage(systemName: "location.fill"), for: .normal)
        currentLocation.addTarget(self, action: #selector(currentUserLocation(_:)), for: .touchUpInside)
        self.view.addSubview(currentLocation)
    }
    
    func useGeocoder(completion: @escaping (Result<Bool, Error>) -> Void) {
        if fromLocationCoordinate == nil {
            // Retrieve the coordinates for the destination address
            mapsModelObject.getLocationFromAddress(address: self.addressSearchBar.text ?? "") { isSucceeded, placemarks, error in
                if isSucceeded {
                    if let placemark = placemarks {
                        self.fromLocationCoordinate = placemark
                        print(placemark)
                        self.showNavigation()
                        completion(.success(true))
                    } else {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No coordinates found for destination"])
                        completion(.failure(error))
                    }
                } else {
                    let error = error.map { $0 as! any Error as Error } ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                    completion(.failure(error))
                }
            }
        } else if toLocationCoordinate == nil {
            // Retrieve the coordinates for the destination address
            mapsModelObject.getLocationFromAddress(address: self.toSearchBar.text ?? "") { isSucceeded, placemarks, error in
                if isSucceeded {
                    if let placemark = placemarks {
                        self.toLocationCoordinate = placemark
                        print(placemark)
                        self.showNavigation()
                        completion(.success(true))
                    } else {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No coordinates found for destination"])
                        completion(.failure(error))
                    }
                } else {
                    let error = error.map { $0 as! any Error as Error } ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                    completion(.failure(error))
                }
            }
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to perform search, Try again!"])
            completion(.failure(error))
        }
    }


    // reset Coordinates once they are used
    func resetCoordinates() {
        fromLocationCoordinate = nil
        toLocationCoordinate = nil
        print("Coordinates reset")
    }
    
    @IBAction func startButtonAction(_ sender: Any) {
        if fromLocationCoordinate == nil {
            useGeocoder { result in
                switch result {
                case .success(let isSuccess):
                    if isSuccess {
                        print("Geocoding successful while fetching fromLocationCoordinate")
                    } else {
                        print("Geocoding failed while fetching fromLocationCoordinate")
                    }
                case .failure(let error):
                    self.alertUser(title: "Error!", message: "Error which fetching coordinates from geocoder ERROR! \(error.localizedDescription)")
                }
            }
        }

        if toLocationCoordinate == nil {
            useGeocoder { result in
                switch result {
                case .success(let isSuccess):
                    if isSuccess {
                        print("Geocoding successful while fetching toLocationCoordinate")
                    } else {
                        print("Geocoding failed while fetching toLocationCoordinate")
                    }
                case .failure(let error):
                    self.alertUser(title: "Error!", message: "Error which fetching coordinates from geocoder ERROR! \(error.localizedDescription)")
                }
            }
        }

        if fromLocationCoordinate != nil && toLocationCoordinate != nil {
            showNavigation()
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        // Bring back Text Fields and Start Button
        UIView.animate(withDuration: 0.5, animations: {
            self.addressSearchBar.alpha = 1
            self.toSearchBar.alpha = 1
            self.startButton.alpha = 1
            // hide View
            self.locationDetailView.alpha = 0
            self.distanceETALable.text = "Loading ...!"
            self.currentLocation.frame = CGRect(x: 348, y: 728, width: 50, height: 50)
        })
        resetMap()
        resetCoordinates()
    }
    
    @objc func currentUserLocation(_ sender: UIButton) {
        if let userLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okay = UIAlertAction(title: "Okay", style: .default)
        
        alert.addAction(okay)
        self.present(alert, animated: true)
        
    }
    
    func updateSuggestionFrame(rect:CGRect) {
        suggestionsView.frame = rect
        suggestionsTableView.rowHeight = UITableView.automaticDimension
        suggestionsTableView.estimatedRowHeight = 30
        suggestionsTableView.frame = CGRectMake(0, 0, suggestionsView.frame.width, suggestionsView.frame.height + 30)
        closeSuggestions.frame = CGRect(x: suggestionsView.frame.origin.x, y: suggestionsView.frame.origin.y + 90, width: 90, height: 30)
    }
    
    func setupSuggestionsView(){
        suggestionsView.frame = CGRect.zero
        suggestionsTableView.frame = CGRect.zero
        closeSuggestions.frame = CGRect.zero
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self
        suggestionsTableView.register(UINib.init(nibName: "SuggestionTableViewCell", bundle: nil), forCellReuseIdentifier: "Suggestions")
        closeSuggestions.setTitle("Close", for: .normal)
        closeSuggestions.backgroundColor = UIColor.red
        closeSuggestions.addTarget(self, action: #selector(closeSuggestionsView), for: .touchUpInside)
        
        // add round corners
        suggestionsView.layer.cornerRadius = 9
        suggestionsTableView.layer.cornerRadius = 9
        closeSuggestions.layer.cornerRadius = 9
        suggestionsView.addSubview(suggestionsTableView)
        self.suggestionsView.alpha = 0
        self.suggestionsTableView.alpha = 0
        self.closeSuggestions.alpha = 0
        view.addSubview(suggestionsView)
        view.addSubview(closeSuggestions)
    }
    
    func handleSearchResults() {
        UIView.animate(withDuration: 0.3, animations: {
            self.suggestionsView.alpha = 1
            self.suggestionsTableView.alpha = 1
            self.closeSuggestions.alpha = 1
        })
        // Reload the table view
        DispatchQueue.main.async {
            self.suggestionsTableView.reloadData()
        }
    }
    
    @objc func closeSuggestionsView(){
        // hide Suggestion View
        UIView.animate(withDuration: 0.5, animations: {
            self.suggestionsView.alpha = 0
            self.suggestionsTableView.alpha = 0
            self.closeSuggestions.alpha = 0
        })
    }
}

extension ViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        suggestionsTableView.reloadData()
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else { return }
        searchCompleter.queryFragment = text
        self.handleSearchResults()
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        activeSearchBar = searchBar
        let cgrect = CGRect(x: searchBar.frame.origin.x, y: searchBar.frame.origin.y + searchBar.frame.height, width: searchBar.frame.width, height: searchBar.frame.height + 20)
        updateSuggestionFrame(rect: cgrect)
        return true
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Suggestions", for: indexPath) as? SuggestionTableViewCell else { return UITableViewCell()}
        
        cell.setupCellView(title: searchResult.title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchResult = searchResults[indexPath.row]
        mapsModelObject.getLocalSearch(searchCompletion: searchResult) { activeMKLocalSearchCoordinate, error in
            if error == nil {
                if self.activeSearchBar == self.addressSearchBar {
                    self.fromLocationCoordinate = activeMKLocalSearchCoordinate
                } else if self.activeSearchBar == self.toSearchBar {
                    self.toLocationCoordinate = activeMKLocalSearchCoordinate
                }
            }
        }
        
        if activeSearchBar != nil {
            activeSearchBar?.text = searchResult.title
        }
        
        // hide Suggestion View
        UIView.animate(withDuration: 0.5, animations: {
            self.suggestionsView.alpha = 0
            self.suggestionsTableView.alpha = 0
            self.closeSuggestions.alpha = 0
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
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
        let identifier = "MyPin"
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            if annotation.title == addressSearchBar.text ?? "" {
                if addressSearchBar.text != "User Location" {
                    annotationView?.image = UIImage(named: "user.png")
                }
            } else if annotation.title == toSearchBar.text ?? "" {
                if toSearchBar.text != "User Location" {
                    annotationView?.image = UIImage(named: "location.png")
                }
            }
        } else {
            annotationView?.annotation = annotation
        }
        
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
        addressSearchBar.text = ""
        toSearchBar.text = ""
    }
}

