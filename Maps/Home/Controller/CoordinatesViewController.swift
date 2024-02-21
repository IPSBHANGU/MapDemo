//
//  CoordinatesViewController.swift
//  Maps
//
//  Created by Inderpreet Singh on 21/02/24.
//

import UIKit

class CoordinatesViewController: UIViewController {

    // Call Database Class
    let dataBase = DataBase.shared

    // empty array for Location Object
    var location:[Location] = []
    
    @IBOutlet weak var coordinatesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        fetchCoordinates()
        // Do any additional setup after loading the view.
    }

    func setupTableView(){
        coordinatesTableView.delegate = self
        coordinatesTableView.dataSource = self
        coordinatesTableView.register(UINib.init(nibName: "CoordinatesTableViewCell", bundle: nil), forCellReuseIdentifier: "Coordinates")
    }
    
    func fetchCoordinates(){
        let fetchDestinationCoordinates = dataBase.fetchCoordinatesCommon(model: Location.self)
        
        // handle result enum
        switch fetchDestinationCoordinates {
        case .success(let data):
            if let data = data {
                location = data
            }
        case .failure(let error):
            print("Error: \(error)")
        }
        coordinatesTableView.reloadData()
    }

}

extension CoordinatesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return location.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Coordinates", for: indexPath) as? CoordinatesTableViewCell else { return UITableViewCell()}
        
        let locationNames = location[indexPath.row].name
        
        cell.setupCellView(fromLocation: locationNames?.components(separatedBy: " ").first ?? "", toLocation: locationNames?.components(separatedBy: " ").last ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let historyLocationView = HistoryLocationViewController()
        historyLocationView.location = location[indexPath.row]
        navigationController?.pushViewController(historyLocationView, animated: true)
    }
}
