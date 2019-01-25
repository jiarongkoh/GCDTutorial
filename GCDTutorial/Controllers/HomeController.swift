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
    
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Cars", "Planes"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    var photosArray = [Photo]()
    
//    var photoRealm = try! Realm()
//    var transportRealm = try! Realm()
    var realm = try! Realm()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupRealm()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        setupDefaultRealm()
//        setupRealm()
        setupUI()
        setupCollectionView()
        setupInitialData()
    }
    
    //MARL:- Setup
    fileprivate func setupDefaultRealm() {
        
        
        
        
    }
    
    
    
    fileprivate func setupRealm() {
        guard let photoRealmFileURL = Realm.Configuration.getFileURL("Photo.realm") else {return}
//        guard let transportRealmFileURL = Realm.Configuration.getFileURL("Transport.realm") else {return}
        print(photoRealmFileURL)
        let photoConfig = Realm.Configuration(fileURL: photoRealmFileURL, objectTypes: [Photo.self])
//        let tranportConfig = Realm.Configuration(fileURL: transportRealmFileURL, objectTypes: [Transport.self])

        do {
//            photoRealm = try Realm(configuration: photoConfig)
//            transportRealm = try Realm(configuration: tranportConfig)
//
//            let cars = Transport()
//            cars.name = "cars"
//
//            let planes = Transport()
//            planes.name = "planes"
//
//            try transportRealm.write {
//                transportRealm.add(cars)
//                transportRealm.add(planes)
//            }

        } catch let error {
            print("Error setting Photo Realm: ", error.localizedDescription)
        }
    }
    
    fileprivate func setupUI() {
        collectionView.backgroundColor = .white
        
        navigationItem.titleView = segmentedControl
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Read Realm", style: .plain, target: self, action: #selector(readRealm))
        
        view.addSubview(toolBar)
        toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let toolBarItems = [UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAllButtonTapped)),
                            flexibleSpaceItem,
                            UIBarButtonItem(title: "Fetch Photos", style: .plain, target: self, action: #selector(fetchButtonTapped))]
        toolBar.items = toolBarItems
    
    }
    
    fileprivate func setupCollectionView() {
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    fileprivate func setupInitialData() {
        let realm = try! Realm()
        let objects = realm.objects(Photo.self)
        photosArray = objects.map({ (photo) -> Photo in
            return photo
        })
    }
    
    //MARK:- Button Actions
    @objc fileprivate func fetchButtonTapped() {
        let alertController = UIAlertController(title: "Fetch Photos", message: nil, preferredStyle: .actionSheet)
        let fetchPhotosByDispatchGroup = UIAlertAction(title: "By Dispatch Group", style: .default) { (_) in
            self.fetchPhotosByDispatchGroup()
        }
        
        let fetchPhotosSynchronously = UIAlertAction(title: "Asynchronously", style: .default) { (_) in
            self.fetchPhotosAsynchronously()
        }
        
        let fetchPhotosWithSemaphore = UIAlertAction(title: "With Semaphore", style: .default) { (_) in
//            self.fetchPhotosWithSemaphore()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(fetchPhotosByDispatchGroup)
        alertController.addAction(fetchPhotosSynchronously)
        alertController.addAction(fetchPhotosWithSemaphore)
        present(alertController, animated: true, completion: nil)
        
    }
    
     @objc fileprivate func clearAllButtonTapped() {
        let deleteQueue = DispatchQueue(label: "deleteQueue", qos: .background)
        
        deleteQueue.async {
            self.deleteAllPhotosFromRealm()
            
            DispatchQueue.main.async {
                self.deletePhotosFromCollectionView()
            }
        }
    }
    
    fileprivate func insertPhotosToCollectionView() {
        var indexPathsToAdd = [IndexPath]()
        
        for (index, _) in self.photosArray.enumerated() {
            let indexPath = IndexPath(item: index, section: 0)
            indexPathsToAdd.append(indexPath)
        }
        self.collectionView.insertItems(at: indexPathsToAdd)
    }
    
    fileprivate func deletePhotosFromCollectionView() {
        var indexPathsToDelete = [IndexPath]()
        
        for (index, _) in self.photosArray.enumerated() {
            let indexPath = IndexPath(item: index, section: 0)
            indexPathsToDelete.append(indexPath)
        }
        
        self.photosArray.removeAll()
        self.collectionView.deleteItems(at: indexPathsToDelete)
    }
    
    fileprivate func deleteSelectedPhotoFromRealm(photo: Photo) {
        let realm = try! Realm()
        let selectedRealmPhoto = realm.objects(Photo.self).filter("id == %@", photo.id ?? "")
        
        try! realm.write {
            realm.delete(selectedRealmPhoto)
        }
    }
    
    
    //MARK:- Realm
    fileprivate func savePhotoToRealm(photo: Photo) {
//        guard let photoFileURL = Realm.Configuration.getFileURL("Photo.realm") else {return}
//
//        let config = Realm.Configuration(fileURL: photoFileURL)
        
        do {
//            let realm = try Realm(configuration: config)
            let realm = try Realm()
            
            let realmPhoto = Photo()
            realmPhoto.id = photo.id
            realmPhoto.farm = photo.farm
            realmPhoto.server = photo.server
            realmPhoto.secret = photo.secret
            realmPhoto.imageData = photo.imageData
            
            try realm.write {
                realm.add(realmPhoto)
            }
        } catch let error {
            print("Error writing to photo realm: ", error.localizedDescription)
        }
        
    }
    
    fileprivate func saveToRealm() {
        let realm = try! Realm()
        
        photosArray.forEach { (photo) in
            try! realm.write {
                realm.add(photo)
            }
        }
        
    }
    
    fileprivate func deleteAllPhotosFromRealm() {
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    @objc fileprivate func readRealm() {
        let queue2 = DispatchQueue(label: "queue2", qos: .background)
        let lock = NSLock()
        
        queue2.async {
            print("Queue2 start")
            let realm = try! Realm()
            let objects = realm.objects(Photo.self)
            
            lock.lock()
            objects.forEach({ (photo) in
                print("Photo", photo.id ?? "", Thread.current)
            })
            
            lock.unlock()
        }
    }
    
    //MARK:- Networking Fetch
    
    /*
    This function will fetch photosInformation from Flickr first, and then download the photoData one by one.
    The intent is to wait for all photos downloading to be completed and then refresh the UI once.
    */
    fileprivate func fetchPhotosByDispatchGroup() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching..."
        hud.show(in: self.view)
        
        FlickrClient.shared.getPhotoListWithText("cars") { [weak self] (photos, error) in
            print("Get Photos With Text Thread Completed:", Thread.current) //background
            
            DispatchQueue.main.async {
                hud.textLabel.text = "Downloading..."
            }

            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let photos = photos {
                let downloadGroup = DispatchGroup()
                
                photos.forEach({ (photo) in
                    downloadGroup.enter()
                    
                    //getImageData is called on background thread concurrently
                    FlickrClient.shared.downloadImageData(photo, { (data, error) in
                        
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        
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
    fileprivate func fetchPhotosAsynchronously() {
        FlickrClient.shared.getPhotoListWithText("planes", completion: { (photos, error) in
            print("Get Photos With Text Thread Completed:", Thread.current) //background

            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let photos = photos else {return}
       
            let queue = DispatchQueue(label: "queue1", qos: .background, attributes: .concurrent)
           
            for (index, _) in photos.enumerated() {
                queue.async(flags: .barrier) {
                    FlickrClient.shared.downloadImageData(photos[index], { (data, error) in
                        print("\(index) Get images:", Thread.current) //background, but asynchronously

                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }

                        if let data = data {
                            let photo = photos[index]
                            photo.imageData = data
                            self.savePhotoToRealm(photo: photo)
                            
                            DispatchQueue.main.async {
                                self.photosArray.append(photo)
                                let indexPath = IndexPath(item: self.photosArray.count - 1, section: 0)
                                self.collectionView.insertItems(at: [indexPath])
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
    
    
    //MARK:- CollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCell
        let photo = photosArray[indexPath.row]
        cell.idLabel.text = photo.id ?? ""
        if let data = photo.imageData {
            cell.imageView.image = UIImage(data: data)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3 - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPhoto = photosArray[indexPath.item]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.deleteSelectedPhotoFromRealm(photo: selectedPhoto)
            
            DispatchQueue.main.async {
                self.photosArray.remove(at: indexPath.item)
                self.collectionView.deleteItems(at: [indexPath])
            }
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
}

