//
//  HistoryTableViewCell.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-03.
//  Copyright © 2020 Louise Chan. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var lblOrderAmount: UILabel!
    @IBOutlet weak var lblOrderItem: UILabel!
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblOrderNo: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
