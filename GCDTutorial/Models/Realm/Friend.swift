//
//  Friend.swift
//  GCDTutorial
//
//  Created by Koh Jia Rong on 2019/1/28.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import Foundation
import RealmSwift

class Friend: Object {
    @objc dynamic var id: String? = nil
    @objc dynamic var name: String? = nil
    var age = RealmOptional<Int>()
    @objc dynamic var gender: String? = nil

    
    override static func primaryKey() -> String? {
        return "id"
    }

}
