//
//  ViewController.swift
//  GCDTutorial
//
//  Created by Koh Jia Rong on 2019/1/16.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import UIKit
import RealmSwift
import JGProgressHUD

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    //UI Elements
    let toolBar: UIToolbar = {
        let tb = UIToolbar()
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Cars", "Planes"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return sc
    }()
    
    var searchText: String = "Cars"
    
    var photosArray = [Photo]()
    
    // Realm
    lazy var realm = try! Realm()
    var token: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        subscribeToRealmNotifications()
        setupUI()
        setupCollectionView()
    }
    
    deinit {
        token?.invalidate()
    }
    
    //MARK:- Setup
    fileprivate func setupUI() {
        collectionView.backgroundColor = .white
        
        navigationItem.titleView = segmentedControl
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAllButtonTapped))
        
        let buttons = [UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(fetchPhotosAsynchronously)),
                       UIBarButtonItem(title: "Read", style: .plain, target: self, action: #selector(readRealm))]
        
        navigationItem.rightBarButtonItems = buttons
    }
    
    fileprivate func setupCollectionView() {
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    fileprivate func setupInitialData() {
        do {
            let realm = try Realm()
            let objects = realm.objects(Photo.self)
            photosArray = objects.map({ (photo) -> Photo in
                return photo
            })
            
        } catch let error {
            NSLog("Error setting up initial data: %@", error.localizedDescription)
        }
    }
    
    fileprivate func subscribeToRealmNotifications() {
        do {
            let realm = try Realm()
            let results = realm.objects(Photo.self)
            
            token = results.observe({ (changes) in
                switch changes {
                case .initial:
                    self.setupInitialData()
                    self.collectionView.reloadData()
                    
                case .update(_, _, let insertions, _):
                    if !insertions.isEmpty {
                        self.handleInsertionsWhenNotified(insertions: insertions)
                    }

                case .error(let error):
                    self.handleError(error as NSError)
                }
            })
            
        } catch let error {
            NSLog("Error subscribing to Realm Notifications: %@", error.localizedDescription)
        }
    }
    
    static var num: Int = 0
    var array = NSArray()
    var mutableArray = NSMutableArray()
    var detachedPhotoArray = Array<Photo>()
    var safePhotoArray = [PhotoSafeObject]()
    
    fileprivate func handleInsertionsWhenNotified(insertions: [Int]) {
        let lock = NSLock()
        let queue = DispatchQueue(label: "queue", qos: .userInitiated)

        queue.async {
            do {
                HomeController.num += 1

                if HomeController.num > 1 {
//                    return
                }

                let realm = try Realm()
                realm.refresh()
                let objects = realm.objects(Photo.self)

                lock.lock()
                for insertion in insertions {
                    let photo = objects[insertion]
                    self.update(photo: photo)
                }

                ///Making photos accessible just before the end of the Realm's lifecycle so that we can use it outside.
                ///Using class for PhotoSafeObject will not crash.
                ///Mapping to structs or Array<Photo> will crash the app because Realm no longer holds the photo object.
//                self.safePhotoArray = objects.map({ (photo) -> PhotoSafeObject in
//                    return PhotoSafeObject(photo: photo)
//                })
                
                ///To make a temporary copy of the realm objects, use a detached array
                ///https://stackoverflow.com/questions/31707157/detach-an-object-from-a-realm
                ///A value type of class types
                self.detachedPhotoArray = objects.map({ (photo) -> Photo in
                    return Photo(value: photo)
                })
            
                ///A class type of class types
                self.mutableArray = NSMutableArray(array: (self.detachedPhotoArray))

                ///Use NSArray instead of NSMutableArray
                self.array = NSArray(array: self.detachedPhotoArray)
                lock.unlock()

            } catch let error {
                NSLog("Error updating photos in Realm Notifications", error.localizedDescription)
            }
        }
        
        let readQueue = DispatchQueue(label: "readQueue", qos: .userInitiated, attributes: .concurrent)

        readQueue.async {
            lock.lock()
//            self.safePhotoArray.forEach({ (photo) in
//                print(photo.id ?? "", Thread.current)
//            })
        
            print(Unmanaged.passRetained(self.mutableArray).toOpaque())
            self.mutableArray.forEach({ (object) in
                let photo = object as! Photo
                print(Unmanaged.passRetained(photo).toOpaque(),  photo.id ?? "", Thread.current)
            })
            lock.unlock()
        }
    }
    
    //MARK:- Realm
    fileprivate func savePhotoToRealm(photo: Photo) {
        do {
            try autoreleasepool {
                
                let realm = try Realm()
                let realmPhoto = createCopy(photo: photo)
                let existingPhoto = realm.objects(Photo.self).filter("id == %@", photo.id ?? "")

                if existingPhoto.isEmpty {
                    try realm.write {
                        realm.add(realmPhoto)
                        NSLog("Successfully saved photo: %@", photo.id ?? "")
                    }
                }
            }
        } catch let error {
            print("Error writing to photo realm: ", error.localizedDescription)
        }
    }

    func deleteAllPhotosFromRealm() {
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.deleteAll()
            }
        } catch let error {
            NSLog("Error deleting all photos from realm: %@", error.localizedDescription)
        }
        
    }
    
    @objc fileprivate func readRealm() {
        let lock = NSLock()
        
        print(Unmanaged.passRetained(mutableArray).toOpaque())
        array.forEach({ (object) in
            let photo = object as! Photo
            photo.name = photo.secret ?? ""
            print(Unmanaged.passRetained(photo).toOpaque(), photo.id ?? "")
        })
        
        
        
//        DispatchQueue.global(qos: .background).async {
//            let realm = try! Realm()
//            let objects = realm.objects(Photo.self)
//
//            lock.lock()
//            objects.forEach({ (photo) in
//                print("Reading Photo", photo.id ?? "", Thread.current)
////                self.updateName(photo: photo)
//            })
//            lock.unlock()
//        }
    }
    
    func update(photo: Photo) {
        do {
            let realm = try Realm()
            let updatedPhoto = createCopy(photo: photo)
            
            let transport = Transport()
            transport.name = searchText
            updatedPhoto.transport = transport
            
            try realm.write {
                realm.add(updatedPhoto, update: true)
                NSLog("Successfully updated photo: %@", photo.id ?? "")
            }
        } catch let error {
            NSLog("Error updating photo name on realm: %@", error.localizedDescription)
        }
    }
    
    func createCopy(photo: Photo) -> Photo {
        let copiedPhoto = Photo()
        copiedPhoto.id = photo.id
        copiedPhoto.farm = photo.farm
        copiedPhoto.server = photo.server
        copiedPhoto.secret = photo.secret
        copiedPhoto.imageData = photo.imageData
        copiedPhoto.name = photo.name
        return copiedPhoto
    }
    
    //MARK:- Networking Fetch
    
    /*
    This function will fetch photosInformation from Flickr first, and then download the photoData one by one.
    The intent is to wait for all photos downloading to be completed and then refresh the UI once.
    */
    func fetchPhotosByDispatchGroup() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching..."
        hud.show(in: self.view)
        
        FlickrClient.shared.getPhotoListWithText("cars") { [weak self] (photos, error) in
            print("Get Photos With Text Completed:", Thread.current) //background
            
            DispatchQueue.main.async {
                hud.textLabel.text = "Downloading..."
            }

            self?.handleError(error)
            
            if let photos = photos {
                let downloadGroup = DispatchGroup()
                
                photos.forEach({ (photo) in
                    downloadGroup.enter()
                    
                    //getImageData is called on background thread concurrently
                    FlickrClient.shared.downloadImageData(photo, { (data, error) in
                        self?.handleError(error)
                        
                        if let data = data {
                            photo.imageData = data
                            
                            self?.savePhotoToRealm(photo: photo)
                            self?.photosArray.append(photo)
                            downloadGroup.leave()
                        }
                    })
                })
                
                //Once all images are downloaded, move to main thread to reload collectionView
                downloadGroup.notify(queue: .main, execute: {
                    self?.collectionView.reloadData()
                    hud.dismiss()
                })
            }
        }
    }

    /*
    This function fetches photoInformation from Flickr, and then moved the operation synchronously to download
    photoData. Once each photoData is downloaded, it is added to the UI via the main thread.
    */
    @objc func fetchPhotosAsynchronously() {
        FlickrClient.shared.getPhotoListWithText(searchText, completion: { [weak self] (photos, error) in
            print("Get Photos With Text Completed:", Thread.current) //background

            self?.handleError(error)
            
            guard let photos = photos else {return}
            
            let queue = DispatchQueue(label: "queue1", qos: .userInitiated , attributes: .concurrent)
            
            queue.async { // Redundant?
                for (index, _) in photos.enumerated() {
                    FlickrClient.shared.downloadImageData(photos[index], { (data, error) in
//                        print("Get images \(index):", Thread.current) //background, but asynchronously

                        self?.handleError(error)

                        if let data = data {
                            let photo = photos[index]
                            photo.imageData = data
                            self?.savePhotoToRealm(photo: photo)
                            
                            DispatchQueue.main.async {
                                self?.photosArray.append(photo)
                                
                                if let count = self?.photosArray.count {
                                    let indexPath = IndexPath(item: count - 1, section: 0)
                                    self?.collectionView.insertItems(at: [indexPath])
                                }
                            }
                        }
                    })
                }
            }
        })
    }
    
    


//
//    /*
//    This function is intended to forcefully do both operations back to back, that is to wait for the photoInformation from Flickr to complete, and then hold them in an array.
//    Once this is completed, we then move over to download each photoData.
//    */
//    func fetchPhotosWithSemaphore() {
//        var tempPhotosArray = [Photo]()
//        let semaphore = DispatchSemaphore(value: 0)
//
////        let hud = JGProgressHUD(style: .dark)
////        hud.textLabel.text = "Downloading..."
////
////        DispatchQueue.main.async {
////            hud.show(in: self.view)
////        }
//
//        FlickrClient.shared.getPhotoListWithText("hamster", completion: { (photos, error) in
//            print("Get Photos With Text", Thread.current)
//
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//
//            if let photos = photos {
//                tempPhotosArray = photos
//                print(1)
//                semaphore.signal()
//            }
//
//        })
//        print(2)
//        semaphore.wait() // Waits for semaphore to signal, then move to 3
//        print(3)
//
////        let downloadGroup = DispatchGroup()
//        for (i,_) in tempPhotosArray.enumerated() {
////            downloadGroup.enter()
//            FlickrClient.shared.downloadImageData(tempPhotosArray[i], { (data, error) in
////                print("\(i) Get images:", Thread.current)
//
//                if let error = error {
//                    print(error.localizedDescription)
//                    return
//                }
//
//                if let data = data {
//                    let realmQueue = DispatchQueue(label: "realmQueue", qos: .background)
//
//                    realmQueue.async {
//                        let photo = tempPhotosArray[i]
//                        photo.imageData = data
//                        self.savePhotoToRealm(photo: photo)
//
//                        DispatchQueue.main.async {
//                            self.photosArray.append(photo)
//                            let indexPath = IndexPath(item: self.photosArray.count - 1, section: 0)
//                            self.collectionView.insertItems(at: [indexPath])
////                            downloadGroup.leave()
//                        }
//                    }
//                }
//            })
//
////            downloadGroup.notify(queue: .main, execute: {
////                hud.dismiss()
////            })
//        }
//    }
    
    func handleError(_ error: NSError?) {
        if let error = error {
            NSLog("%@", error.localizedDescription)
            return
        }
    }
    
}

