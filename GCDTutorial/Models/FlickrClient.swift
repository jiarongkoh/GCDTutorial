//
//  FlickrClient.swift
//  GCDTutorial
//
//  Created by Koh Jia Rong on 2019/1/16.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import Foundation

struct PhotoStruct {
    let id: String?
    let secret: String?
    let server: String?
    let farm: Int
    var imageData: Data? = nil
    
    init(id: String?, secret: String?, server: String?, farm: Int, imageData: Data?) {
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
        self.imageData = imageData
    }
    
    func getImageUrl() -> URL {
        var components = URLComponents()
        components.scheme = Constants.APIScheme
        components.host = "farm\(farm).staticflickr.com"
        components.path = "/\(server ?? "")/\(id ?? "")_\(secret ?? "").jpg"
        
        return components.url!
    }
}

class FlickrClient: NSObject {
    
    static let shared = FlickrClient()
    
    var session = URLSession.shared
    
    override init() {
        super.init()
    }
    
    func getPhotoListWithText(_ text: String, completion: @escaping (_ photos: [Photo]?, _ error: NSError?) -> Void) {        
        let parameters = [Constants.FlickrKeys.Method: Constants.FlickrValues.FlickrPhotosSearch,
                          Constants.FlickrKeys.APIKey: Constants.FlickrValues.APIKey,
                          Constants.FlickrKeys.Format: Constants.FlickrValues.JSON,
                          Constants.FlickrKeys.NoJSONCallback: Constants.FlickrValues.NoJSONCallback,
                          Constants.FlickrKeys.Text: text,
                          Constants.FlickrKeys.PerPage: Constants.FlickrValues.PerPage,
                          Constants.FlickrKeys.SafeSearch: Constants.FlickrValues.SafeSearch] as [String : AnyObject]
        
        let url = urlFromParameters(apiScheme: Constants.APIScheme, apiHost: Constants.APIHost, apiPath: Constants.APIPath, parameters)
        
        let dataTask = session.dataTask(with: url) { (data, respose, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error as NSError)
            }
            
            self.convertToJSON(data, { (results, error) in
                if let error = error {
                    print(error.localizedDescription)
                    completion(nil, error)
                }
                
                guard let results = results as? [String: AnyObject] else {return}
                guard let photos = results["photos"] as? [String: AnyObject] else {return}
                guard let photosArray = photos["photo"] as? [[String: AnyObject]] else {return}
                
                let array = photosArray.map({ (dictionary) -> Photo in
                    let photo = Photo()
                    photo.id = dictionary["id"] as? String
                    photo.server = dictionary["server"] as? String
                    photo.farm = dictionary["farm"] as! Int
                    photo.secret = dictionary["secret"] as? String
                    return photo
                })
                
                completion(array, nil)
            })
        }
        
        dataTask.resume()
    
    }
    
    func downloadImageData(_ photo: Photo, _ completion: @escaping (_ data: Data?, _ error: NSError?) -> Void) {
        
        let dataTask = session.dataTask(with: photo.getImageUrl()) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error as NSError)
            }
            
            if let data = data {
                completion(data, nil)
            }
        }
        
        dataTask.resume()
    }
    
    func urlFromParameters(apiScheme: String, apiHost: String, apiPath: String, _ parameters: [String:AnyObject]?) -> URL {
        
        var components = URLComponents()
        components.scheme = apiScheme
        components.host = apiHost
        components.path = apiPath
        components.queryItems = [URLQueryItem]()

        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    func convertToJSON(_ data: Data?, _ completion: @escaping (_ results: AnyObject?, _ error: NSError?) -> Void) {
        var results: AnyObject?
        
        if let data = data {
            do {
                results = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not convert the data to JSON: '\(data)'"]
                completion(nil, NSError(domain: "convertToJSON", code: 1, userInfo: userInfo))
            }
            
            completion(results, nil)
        } else {
            let userInfo = [NSLocalizedDescriptionKey : "Data is nil"]
            completion(nil, NSError(domain: "convertToJSON", code: 1, userInfo: userInfo))
        }
    }
    
}
