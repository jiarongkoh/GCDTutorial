//
//  MainTabBarController.swift
//  GCDTutorial
//
//  Created by Koh Jia Rong on 2019/1/28.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        let homeController = HomeController(collectionViewLayout: layout)
        let homeNavController = createNavigationController(viewController: homeController, title: "Home", iconName: "baseline_home_black_24pt")
        
        let friendsController = FriendsController()
        let friendsNavController = createNavigationController(viewController: friendsController, title: "Friends", iconName: "baseline_people_black_24pt")
        viewControllers = [homeNavController, friendsNavController]
        
        selectedIndex = 0
    }
    
    func createNavigationController(viewController: UIViewController, title: String, iconName: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: iconName)
        return navController
    }
}
