//
//  RetainCycleController.swift
//  GCDTutorial
//
//  Created by Koh Jia Rong on 2019/1/21.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import UIKit

class People {
    let name: String
    var apartment: Apartment?              // 人住的公寓属性
    
    deinit {
        print("\(name) is being deinitialized")
    }
    
    init(name: String) {
        self.name = name
        print("\(name) is being initialized")
    }
    
}

class Apartment {
    let unit: String
    
    // Remove the weak to try
    // When defined weak, memory can be deallocated
    // Because tenant has a weak relationship with people
    weak var tenant: People?
    
    deinit {
        print("\(unit) is being deinitialized")
    }
    
    init(unit: String) {
        self.unit = unit
        print("\(unit) is being initialized")
    }
    
}

class RetainCycleController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(pushToBlueController))
        
    }
    
    @objc func pushToBlueController() {
        let vc = BlueTableViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

class BlueTableViewController: UITableViewController {
    
    var completionCallback: (()->())?
    
    deinit {
        print("Blue controller being deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .blue

        loadData { [weak self] in
            print(self?.view)
        }
    }
    
    func loadData(completion: @escaping ()->()) -> () {
        
        completionCallback = completion
        
        DispatchQueue.global().async {
            print("do work")
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
}
