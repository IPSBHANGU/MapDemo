//
//  HistoryLocationViewController.swift
//  Maps
//
//  Created by Inderpreet Singh on 21/02/24.
//

import UIKit
import MapKit

class HistoryLocationViewController: UIViewController {

    var location:Location?
    var storedPolylineCoordinates: [CLLocationCoordinate2D] = []
    var path:MKPolyline?
    
    // details View
    let detailsView = UIView()
    let okayButton = UIButton()
    let fromLocationLable = UILabel()
    let fromLocationCoordinatesLable = UILabel()
    let toLocationLable = UILabel()
    let toLocationCoordinatesLable = UILabel()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setMapView()
        fetchRoute()
        locationHistory()
        setupHistory()
        drawPath()
        print(storedPolylineCoordinates)
        // Do any additional setup after loading the view.
    }

    func setMapView() {
        mapView.delegate = self
    }

    func fetchRoute() {
        guard let location = location, let polylineData = location.path else { return }

        let pointsCountRange = 0..<MemoryLayout<UInt>.size
        var pointsCount: UInt = 0
        polylineData.withUnsafeBytes { rawBufferPointer in
            guard let baseAddress = rawBufferPointer.baseAddress else { return }
            let buffer = baseAddress.assumingMemoryBound(to: UInt.self)
            pointsCount = buffer[0]
        }

        let pointsRangeStart = pointsCountRange.upperBound
        let pointsRangeEnd = pointsRangeStart + MemoryLayout<MKMapPoint>.stride * Int(pointsCount)
        let pointsRange = pointsRangeStart..<pointsRangeEnd
        let pointsData = polylineData.subdata(in: pointsRange)

        var polylinePoints = [MKMapPoint]()
        pointsData.withUnsafeBytes { bytes in
            let buffer = bytes.bindMemory(to: MKMapPoint.self)
            for i in 0..<Int(pointsCount) {
                polylinePoints.append(buffer[i])
            }
        }

        let polyline = MKPolyline(points: polylinePoints, count: Int(pointsCount))
        path = polyline
        storedPolylineCoordinates.append(polyline.coordinate)
    }

    
    func locationHistory(){
        detailsView.frame = CGRect(x: 30, y: 50, width: 354, height: 714)
        okayButton.frame = CGRect(x: 120, y: 640, width: 75, height: 40)
        fromLocationLable.frame = CGRect(x: 34, y: 120, width: 286, height: 40)
        fromLocationCoordinatesLable.frame = CGRect(x: 34, y: 140, width: 286, height: 40)
        toLocationLable.frame = CGRect(x: 34, y: 160, width: 286, height: 40)
        toLocationCoordinatesLable.frame = CGRect(x: 34, y: 180, width: 286, height: 40)
        okayButton.setTitle("Okay", for: .normal)
        okayButton.layer.cornerRadius = 9
        okayButton.addTarget(self, action: #selector(okayTutorialAction), for: .touchUpInside)
        okayButton.alpha = 1
        okayButton.backgroundColor = .black
        fromLocationLable.alpha = 1
        fromLocationCoordinatesLable.alpha = 1
        toLocationLable.alpha = 1
        toLocationCoordinatesLable.alpha = 1
        detailsView.alpha = 1
        detailsView.addSubview(okayButton)
        detailsView.addSubview(fromLocationLable)
        detailsView.addSubview(fromLocationCoordinatesLable)
        detailsView.addSubview(toLocationLable)
        detailsView.addSubview(toLocationCoordinatesLable)
        detailsView.backgroundColor = UIColor.white
        view.addSubview(detailsView)
    }
    
    @objc func okayTutorialAction(){
        UIView.animate(withDuration: 0.5, animations: {
            self.detailsView.alpha = 0
            self.okayButton.alpha = 0
            self.fromLocationLable.alpha = 0
            self.fromLocationCoordinatesLable.alpha = 0
            self.toLocationLable.alpha = 0
            self.toLocationCoordinatesLable.alpha = 0
            self.okayButton.removeFromSuperview()
            self.fromLocationLable.removeFromSuperview()
            self.fromLocationCoordinatesLable.removeFromSuperview()
            self.toLocationLable.removeFromSuperview()
            self.toLocationCoordinatesLable.removeFromSuperview()
            self.detailsView.removeFromSuperview()
        })
    }
    
    func setupHistory(){
        fromLocationLable.text = location?.name?.components(separatedBy: " ").first ?? ""
        fromLocationCoordinatesLable.text = "\(location?.fromCoordinates ?? 0)"
        toLocationLable.text = location?.name?.components(separatedBy: " ").last ?? ""
        toLocationCoordinatesLable.text = "\(location?.toCoordinates ?? 0)"
    }
    
    func setAnnotation(location:CLLocation , title : String){
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = location.coordinate
        self.mapView.addAnnotation(annotation)
        let view = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        self.mapView.setRegion(view, animated: true)
    }
}

extension HistoryLocationViewController: MKMapViewDelegate {
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
//            if annotation.title ==  ?? "" {
//                annotationView?.image = UIImage(named: "user.png")
//            } else if annotation.title == toSearchBar.text ?? "" {
//                annotationView?.image = UIImage(named: "location.png")
//            }
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func drawPath() {
        guard let path = path else { return }
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.addOverlay(path)
        
        // Logic/Idea from https://github.com
        // Implementation by @Indepreet
        // Should clean it later on
        
        guard storedPolylineCoordinates.count >= 2 else { return }
        
        setAnnotation(location: CLLocation(latitude: storedPolylineCoordinates.first!.latitude,
                                            longitude: storedPolylineCoordinates.first!.longitude),
                       title: "Start")
    
        setAnnotation(location: CLLocation(latitude: storedPolylineCoordinates.last!.latitude,
                                            longitude: storedPolylineCoordinates.last!.longitude),
                       title: "End")
        
        let rect = path.boundingMapRect
        mapView.setRegion(MKCoordinateRegion(rect), animated: true)
    }

}
