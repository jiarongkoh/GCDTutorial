//
//  Constants.swift
//  GCDTutorial
//
//  Created by Koh Jia Rong on 2019/1/16.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

struct Constants {
    static let APIScheme = "https"
    static let APIHost = "api.flickr.com"
    static let APIPath = "/services/rest/"
    
    struct FlickrKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Text = "text"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let PerPage = "per_page"
        static let SafeSearch = "safe_search"
    }
    
    struct FlickrValues {
        static let FlickrPhotosSearch = "flickr.photos.search"
        static let APIKey = "cc2555948d7c31848f732ea4e5317f08"
        static let JSON = "json"
        static let NoJSONCallback = 1
        static let PerPage = 10
        static let SafeSearch = 1
        
    }
}
