//
//  MealTableViewCell.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-03.
//  Copyright © 2020 Louise Chan. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell {

    @IBOutlet weak var lblMealCalories: UILabel!
    @IBOutlet weak var lblMealName: UILabel!
    @IBOutlet weak var imgMealPhoto: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
