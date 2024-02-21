//
//  MapsModel.swift
//  Maps
//
//  Created by Inderpreet Singh on 13/02/24.
//

import UIKit
import CoreLocation
import MapKit

class MapsModel: NSObject {
    
    // AppDelegate
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    // Call Database Class
    let dataBase = DataBase.shared
    
    // Get location matching to input string
    func getLocationFromAddress(address:String, completionHandler: @escaping(_ isSucceeded: Bool, _ placemarks: CLLocationCoordinate2D?, _ error: String?)->()) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { placemarks, error in
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location else {
                print("No location found for the given address")
                return
            }
            
            if error == nil {
                completionHandler(true, location.coordinate, nil)
            } else {
                completionHandler(false, nil, error?.localizedDescription)
            }
        }
    }
    
    // Function to get Estimate Time of Arrival
    func getEstimatedTimeOfArrival(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, completion: @escaping (Int?, Error?, String?) -> Void) {
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
                completion(nil, error, nil)
                return
            }
            
            guard let route = response?.routes.first else {
                let error = NSError(domain: "Maps", code: 0, userInfo: [NSLocalizedDescriptionKey: "No route found"])
                completion(nil, error, nil)
                return
            }
            
            let etaInSeconds = route.expectedTravelTime
            let etaInHours = Int(etaInSeconds / 3600) // Convert seconds to hours
            
            if etaInHours < 1 {
                completion(Int(etaInSeconds) / 60, nil, "minutes")
            } else {
                completion(etaInHours, nil, "hours")
            }
        }
    }
    
    // Function to get Distance from start and destination Coordinates
    func getDistance(from sourceCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D) -> String {
            let sourceLocation = CLLocation(latitude: sourceCoordinate.latitude, longitude: sourceCoordinate.longitude)
            let destinationLocation = CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
            
        let distanceInKilometers = sourceLocation.distance(from: destinationLocation) / 1000.0
        let formattedDistance = String(format: "%.2f km", distanceInKilometers)
            return formattedDistance
    }
    
    func getLocalSearch(searchCompletion:MKLocalSearchCompletion ,completionHandler: @escaping (CLLocationCoordinate2D?, Error?) -> ()) {
        let searchRequest = MKLocalSearch.Request(completion: searchCompletion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            } else {
                let coordinate = response!.mapItems[0].placemark.coordinate
                completionHandler(coordinate, nil)
            }
        }
    }
    
    // save from Coordinates
    func storeSearchHistory(fromLocationName:String, toLocationName:String, fromCoordinates: CLLocationCoordinate2D, toCoordinates:CLLocationCoordinate2D, route:MKPolyline) -> (Bool, String, String) {
        guard let context = appDelegate?.persistentContainer.viewContext else {
            return (false, "Error", "Unable to access managed object context")
        }

        let coordinateObject = Location(context: context)
        
        // Location Search Name
        let separator = ", "
        coordinateObject.name = [fromLocationName, toLocationName].joined(separator: separator)
        
        // Coordinates
        coordinateObject.fromCoordinates = fromCoordinates.latitude + fromCoordinates.longitude
        coordinateObject.toCoordinates = toCoordinates.latitude + toCoordinates.longitude
        
        // Route
        do {
            let pointsData = NSMutableData()
            var count = route.pointCount
            var points = route.points()
            
            pointsData.append(&count, length: MemoryLayout<UInt>.size)
            pointsData.append(points, length: MemoryLayout<MKMapPoint>.size * count)
            coordinateObject.path = Data(referencing: pointsData)
        } catch {
            return (false, "Error", "Error while encoding route data: \(error.localizedDescription)")
        }

        let response = dataBase.saveCoordinatesCommon(context: context)

        switch response {
        case .success(_):
            return (true, "", "")
        case .failure(let error):
            return (false, "Error", "Error while saving context: \(error.localizedDescription)")
        }
    }

}
