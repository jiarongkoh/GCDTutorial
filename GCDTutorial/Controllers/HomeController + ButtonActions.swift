//
//  HomeController + ButtonActions.swift
//  GCDTutorial
//
//  Created by Koh Jia Rong on 2019/1/30.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

extension HomeController {
    //MARK:- Button Actions
    @objc func segmentedControlValueChanged(_ segmentedControl: UISegmentedControl) {
        searchText = segmentedControl.selectedSegmentIndex == 0 ? "Cars" : "Planes"
    }
    
    @objc func fetchButtonTapped() {
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
        
        alertController.addActions([cancelAction, fetchPhotosByDispatchGroup, fetchPhotosSynchronously, fetchPhotosWithSemaphore])
        present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func clearAllButtonTapped() {
        DispatchQueue.global(qos: .background).async {
            self.deleteAllPhotosFromRealm()
            
            DispatchQueue.main.async {
                self.deletePhotosFromCollectionView()
            }
        }
    }
    
    fileprivate func insertPhotosToCollectionView() {
        let indexPathsToAdd = convertArrayToIndexPaths()
        collectionView.insertItems(at: indexPathsToAdd)
    }
    
    fileprivate func deletePhotosFromCollectionView() {
        let indexPathsToDelete = convertArrayToIndexPaths()
        
        photosArray.removeAll()
        collectionView.deleteItems(at: indexPathsToDelete)
    }
    
    func convertArrayToIndexPaths() -> [IndexPath] {
        var indexPaths = [IndexPath]()
        
        for (index, _) in self.photosArray.enumerated() {
            let indexPath = IndexPath(item: index, section: 0)
            indexPaths.append(indexPath)
        }
        return indexPaths
    }
    
    func deleteSelectedPhotoFromRealm(photo: Photo) {
        let realm = try! Realm()
        let selectedRealmPhoto = realm.objects(Photo.self).filter("id == %@", photo.id ?? "")
        
        try! realm.write {
            realm.delete(selectedRealmPhoto)
        }
    }
    
    
    
}
