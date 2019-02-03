//
//  Photo.swift
//  GCDTutorial
//
//  Created by Koh Jia Rong on 2019/1/17.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import Foundation
import RealmSwift

class PhotoSafeObject {
    
    var id: String? = nil
    var name: String? = nil
    var secret: String? = nil
    var server: String? = nil
    var farm: Int = 0
    var imageData: Data? = nil
    var transport: Transport?
    
    init(photo: Photo) {
        self.id = photo.id
        self.name = photo.name
        self.secret = photo.secret
        self.server = photo.server
        self.farm = photo.farm
        self.imageData = photo.imageData
        self.transport = photo.transport
    }
    
}


class Photo: Object {
    @objc dynamic var id: String? = nil
    @objc dynamic var name: String? = nil
    @objc dynamic var secret: String? = nil
    @objc dynamic var server: String? = nil
    @objc dynamic var farm: Int = 0
    @objc dynamic var imageData: Data? = nil
    @objc dynamic var transport: Transport?
    
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

struct PersonStruct {
    var name: String?
    var age: Int?
}

class Person: NSObject {
    var name: String?
    var age: Int?
    var gender: String?
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let a = Person()
        a.name = "Peter"
        a.age = 10
        a.gender = "M"
    }
}


