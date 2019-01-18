//
//  AppDelegate.swift
//  GCDTutorial
//
//  Created by Koh Jia Rong on 2019/1/16.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        handleRealmMigration()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        
        let layout = UICollectionViewFlowLayout()
        let homeController = HomeController(collectionViewLayout: layout)
        let navigationController = UINavigationController(rootViewController: homeController)
        window?.rootViewController = navigationController
        
        return true
    }
    
    fileprivate func handleRealmMigration() {
        guard let photoRealmFileURL = Realm.Configuration.getFileURL("Photo.realm") else {return}

        let photoMigrationConfig = Realm.Configuration(fileURL: photoRealmFileURL, schemaVersion: 1, migrationBlock: { (migration, oldSchemaVersion) in
            print("OldSchemaVersion", oldSchemaVersion)
            if (oldSchemaVersion < 2) {
                migration.enumerateObjects(ofType: Photo.className()) { oldObject, newObject in
                    newObject?["tranport"] = "Your value"
                }
            }
        }, objectTypes: [Photo.self])
        
        do {
            let _ = try Realm(configuration: photoMigrationConfig)
        } catch let error {
            print("Migration Error", error.localizedDescription)
        }
            
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

