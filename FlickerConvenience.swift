//
//  FlickerConvenience.swift
//  On The Map
//
//  Created by nacho on 5/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

extension FlickerClient {
    
    public func getImageFromFlickerSearch(student:StudentLocation, delegate:FlickerDelegate) {
        self.getImageFromFlickerSearch(student) { success, result, errorString in
            delegate.didSearchStudentLocationImage(success, imageURL:result, errorString: errorString)
        }
    }
    
    public func getImageFromFlickerSearch(student:StudentLocation, completionHandler:(success:Bool, result:NSURL?, errorString:String?) -> Void) {
        let parameters = [
            FlickerClient.ParameterKeys.METHOD : FlickerClient.Methods.SEARCH,
            FlickerClient.ParameterKeys.API_KEY : FLICKR_API_KEY,
            FlickerClient.ParameterKeys.BBOX : self.createBoundingBoxString(student),
            FlickerClient.ParameterKeys.SAFE_SEARCH : FlickerClient.Constants.SAFE_SEARCH,
            FlickerClient.ParameterKeys.EXTRAS : FlickerClient.Constants.EXTRAS,
            FlickerClient.ParameterKeys.FORMAT : FlickerClient.Constants.DATA_FORMAT,
            FlickerClient.ParameterKeys.NO_JSON_CALLBACK : FlickerClient.Constants.NO_JSON_CALLBACK
        ]
        self.httpClient?.taskForGETMethod("", parameters: parameters) { JSONResult, error in
            if let _ = error {
                completionHandler(success: false, result: nil, errorString: "Can not find photos for location")
            } else  {
                if let photosDictionary = JSONResult.valueForKey("photos") as? [String:AnyObject] {
                
                    if let totalPages = photosDictionary["pages"] as? Int {
                    
                        /* Flickr API - will only return up the 4000 images (100 per page * 40 page max) */
                        let pageLimit = min(totalPages, 40)
                        let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                        self.getImageFromFlickrBySearchWithPage(parameters, pageNumber: randomPage, completionHandler: completionHandler)
                    
                    } else {
                        completionHandler(success:false, result:nil, errorString:"Cant find key 'pages' in result")
                    }
                } else {
                    completionHandler(success:false, result:nil, errorString:"Cant find key 'pages' in result")
                }
            }
        }
    }
    
    private func getImageFromFlickrBySearchWithPage(methodArguments: [String : AnyObject], pageNumber: Int, completionHandler:(success:Bool, result:NSURL?, errorString:String?) -> Void) {
        var withPageDictionary = methodArguments
        withPageDictionary["page"] = pageNumber
        self.httpClient?.taskForGETMethod("", parameters: withPageDictionary) { JSONResult, error in
            if let _ = error {
                completionHandler(success: false, result: nil, errorString: "Can not find photos for location")
            } else {
                if let photosDictionary = JSONResult.valueForKey("photos") as? [String:AnyObject] {
                    var totalPhotosVal = 0
                    if let totalPhotos = photosDictionary["total"] as? String {
                        totalPhotosVal = (totalPhotos as NSString).integerValue
                    }
                
                    if totalPhotosVal > 0 {
                        if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                        
                            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                            let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                        
                            _ = photoDictionary["title"] as? String
                            let imageUrlString = photoDictionary["url_m"] as? String
                            if let imageURL = NSURL(string: imageUrlString!) {
                                completionHandler(success: true, result: imageURL, errorString: nil)
                            } else {
                                completionHandler(success: false, result: nil, errorString: "Image does not exist")
                            }
                        } else {
                            completionHandler(success: false, result: nil, errorString: "Cant find key 'photo' in response")
                        }
                    } else {
                        completionHandler(success: false, result: nil, errorString: "No Photos Found")
                    }
                } else {
                    completionHandler(success: false, result: nil, errorString: "Cant find key 'photo' in response")
                }
            }
        
        }
    }

    private func createBoundingBoxString(student:StudentLocation) -> String {
        
        let latitude = student.latitude!
        let longitude = student.longitude!
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - FlickerClient.Constants.BOUNDING_BOX_HALF_WIDTH, FlickerClient.Constants.LON_MIN)
        let bottom_left_lat = max(latitude - FlickerClient.Constants.BOUNDING_BOX_HALF_HEIGHT, FlickerClient.Constants.LAT_MIN)
        let top_right_lon = min(longitude + FlickerClient.Constants.BOUNDING_BOX_HALF_HEIGHT, FlickerClient.Constants.LON_MAX)
        let top_right_lat = min(latitude + FlickerClient.Constants.BOUNDING_BOX_HALF_HEIGHT, FlickerClient.Constants.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
}
