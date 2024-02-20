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
    var destinationCoordinates: [DestinationCoordinates] = []
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
        let fetchDestinationCoordinates = dataBase.fetchCoordinatesCommon(model: DestinationCoordinates.self)
        
        // handle result enum
        switch fetchDestinationCoordinates {
        case .success(let data):
            if let data = data {
                destinationCoordinates = data
            }
        case .failure(let error):
            print("Error: \(error)")
        }
        coordinatesTableView.reloadData()
    }

}

extension CoordinatesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        destinationCoordinates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Coordinates", for: indexPath) as? CoordinatesTableViewCell else { return UITableViewCell()}
        
        cell.setupCellView(longitude: destinationCoordinates[indexPath.row].longitude ?? "", latitude: destinationCoordinates[indexPath.row].latitude ?? "")
        return cell
    }
    
    
}
