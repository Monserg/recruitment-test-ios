//
//  Value.swift
//  iOSRecruitmentTest
//
//  Created by msm72 on 7/23/16.
//  Copyright © 2016 Snowdog. All rights reserved.
//

import CoreData
import Gloss

class Value: NSObject, Decodable {
    // MARK: - Properties
    var name: String!
    var comment: String?
    var image: String?
    var id: NSNumber!

    
    // MARK: - Initialization
    init(name: String, comment: String, image: String, id: NSNumber) {
        super.init()
        
        self.name = name
        self.comment = comment
        self.image = image
        self.id = id
    }

    required init?(json: JSON) {
        self.id = ("id" <~~ json)!
        self.name = ("name" <~~ json)!
        self.comment = ("description" <~~ json)!
        self.image = ("icon" <~~ json)!
    }
}
