//
//  TableViewCell.swift
//  iOSRecruitmentTest
//
//  Created by Bazyli Zygan on 15.06.2016.
//  Copyright © 2016 Snowdog. All rights reserved.
//

import UIKit
import Nuke

class TableViewCell: UITableViewCell {
    // MARK: - Properties
    var item: Value? {
        didSet {
            if item == nil {
                iconView.image = nil
                itemTitleLabel.text = "Test"
                itemDescLabel.text = "Some description"
            } else {
                // TODO: Implement item sets
                itemTitleLabel.text = item?.name
                itemDescLabel.text = item?.comment
                
                Nuke.taskWith(NSURL(string: (item?.image)!)!) { response in
                    switch response {
                    case let .Success(image, _):
                        //do something with your image
                        self.iconView.image = image
                    
                    case let .Failure(error):
                        //handle the error case
                        print(error)
                    }
                    }.resume()
//                iconView.image = 
            }
        }
    }
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemDescLabel: UILabel!
    
    
    // MARK: - Class Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconView.layer.cornerRadius = 4
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.item = nil
    }
}

