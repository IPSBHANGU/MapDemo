//
//  CoordinatesTableViewCell.swift
//  Maps
//
//  Created by Inderpreet Singh on 21/02/24.
//

import UIKit

class CoordinatesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellView(longitude:String, latitude:String){
        longitudeLabel.text = longitude
        latitudeLable.text = latitude
    }
}
