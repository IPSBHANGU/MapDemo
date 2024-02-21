//
//  CoordinatesTableViewCell.swift
//  Maps
//
//  Created by Inderpreet Singh on 21/02/24.
//

import UIKit

class CoordinatesTableViewCell: UITableViewCell {

    
    // Location Names
    @IBOutlet weak var fromLocationLable: UILabel!
    @IBOutlet weak var toLocationLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellView(fromLocation:String, toLocation:String){
        fromLocationLable.text = fromLocation
        toLocationLable.text = toLocation
    }
}
