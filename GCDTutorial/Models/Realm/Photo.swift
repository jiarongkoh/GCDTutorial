//
//  Photo.swift
//  GCDTutorial
//
//  Created by Koh Jia Rong on 2019/1/17.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import Foundation
import RealmSwift

class Photo: Object {
    @objc dynamic var id: String? = nil
    @objc dynamic var secret: String? = nil
    @objc dynamic var server: String? = nil
    @objc dynamic var farm: Int = 0
    @objc dynamic var imageData: Data? = nil
//    @objc dynamic var tranport: Transport?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getImageUrl() -> URL {
        var components = URLComponents()
        components.scheme = Constants.APIScheme
        components.host = "farm\(farm).staticflickr.com"
        components.path = "/\(server ?? "")/\(id ?? "")_\(secret ?? "").jpg"
        
        return components.url!
    }
}
