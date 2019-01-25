//
//  Extensions.swift
//  GCDTutorial
//
//  Created by Koh Jia Rong on 2019/1/25.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    func addActions(_ actions: [UIAlertAction]) {
        actions.forEach { (action) in
            self.addAction(action)
        }
    }
    
}
