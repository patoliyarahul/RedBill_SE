//
//  MyAccountCell.swift
//  RedBill
//
//  Created by Rahul on 11/9/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit

class MyAccountCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTittle: UILabel!
    @IBOutlet weak var lblDscription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
