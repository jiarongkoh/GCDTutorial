//
//  FriendsController.swift
//  GCDTutorial
//
//  Created by Koh Jia Rong on 2019/1/28.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import UIKit
import RealmSwift

class FriendsController: UITableViewController {
    
    var friends = [Friend]()
    
    //Realm
    lazy var friendRealm = try! Realm()
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToRealmNotifications()
        setupUI()
        setupTableView()
        setupRealm()
        
    }
    
    fileprivate func subscribeToRealmNotifications() {
        guard let friendUrl = Realm.Configuration.getFileURL("Friend.realm") else {return}
        
        do {
            let friendRealm = try Realm(fileURL: friendUrl)
            let results = friendRealm.objects(Friend.self)
            
            token = results.observe({ (changes) in
                switch changes {
                case .initial:
                    self.setupInitialData()
                    self.tableView.reloadData()
                    
                case .update(_, _, let insertions, _):
                    let indexPaths = insertions.map({ (row) -> IndexPath in
                        return IndexPath(row: row, section: 0)
                    })
                    
                    for insertion in insertions {
                        let friend = results[insertion]
                        self.friends.append(friend)
                    }
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                    
                case .error(let error):
                    NSLog("Error Realm Notifications: %@", error.localizedDescription)
                }
            })
            
        } catch let error {
            NSLog("Error subscribing to Realm Notifications: %@", error.localizedDescription)
        }
    }
    
    fileprivate func setupInitialData() {
        let objects = friendRealm.objects(Friend.self)
        friends = objects.map({ (friend) -> Friend in
            return friend
        })
    }
    
    fileprivate func setupUI() {
        navigationItem.title = "Friends"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    fileprivate func setupRealm() {
        guard let friendRealmFileURL = Realm.Configuration.getFileURL("Friend.realm") else {
            print("No friend realm file")
            return
        }
        print(friendRealmFileURL)

        let friendConfig = Realm.Configuration(fileURL: friendRealmFileURL, objectTypes: [Friend.self])
        
        do {
            friendRealm = try Realm(configuration: friendConfig)

        } catch let error {
            print("Error setting Friend Realm: ", error.localizedDescription)
        }
    }
    
    //MARK:- Button Actions
    @objc func addButtonTapped() {
        let alertController = UIAlertController(title: "Type a name", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Name"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?.first {
                let text = textField.text ?? ""
                self.saveToRealm(text: text)
            }
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func saveToRealm(text: String) {
        do {
            let friend = Friend()
            friend.id = UUID().uuidString
            friend.name = text
            friend.age = RealmOptional<Int>(Int.random(in: 18...50))
            friend.gender = "M"
            
            try friendRealm.write {
                friendRealm.add(friend, update: true)
            }

        } catch let error {
            NSLog("Error saving friend to Realm: %@", error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let friend = friends[indexPath.row]
        cell.textLabel?.text = "Name: \(friend.name ?? "") | Age: \(friend.age.value ?? 0)"
        cell.detailTextLabel?.text = "Gender: \(friend.gender ?? "")"
        return cell
    }
}
