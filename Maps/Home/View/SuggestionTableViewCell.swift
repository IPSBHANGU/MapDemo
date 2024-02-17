//
//  SuggestionTableViewCell.swift
//  Maps
//
//  Created by Inderpreet Singh on 13/02/24.
//

import UIKit

class SuggestionTableViewCell: UITableViewCell {


    @IBOutlet weak var titleLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellView(title:String){
        titleLable.text = title
    }
}
