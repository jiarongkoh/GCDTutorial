//
//  Realm + Extensions.swift
//  GCDTutorial
//
//  Created by Koh Jia Rong on 2019/1/18.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm.Configuration {
    
    static func getFileURL(_ directory: String) -> URL? {
        let defaultConfig = Realm.Configuration()
        
        if let fileURL = defaultConfig.fileURL {
            return fileURL.deletingLastPathComponent().appendingPathComponent(directory)
        }
        
        return nil
    }
    
    
}
