//
//  MealkitTableViewCell.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-03.
//  Copyright © 2020 Louise Chan. All rights reserved.
//

import UIKit

class MealkitTableViewCell: UITableViewCell {

    @IBOutlet weak var lblMealkitPrice: UILabel!
    @IBOutlet weak var imgMealkitPicture: UIImageView!
    
    @IBOutlet weak var lblMealkitDescription: UILabel!
    @IBOutlet weak var lblMealkitName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
