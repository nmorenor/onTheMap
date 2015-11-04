//
//  ParseConvenience.swift
//  On The Map
//
//  Created by nacho on 5/1/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

extension ParseClient {
    
    public func postStudentLocationWithDelegate(studentLocation:StudentLocation, delegate:StudentDataUpdateDelegate) {
        if let _ = studentLocation.objectId {
            self.updateStudentLocation(studentLocation) { success, student, errorString in
                if (success) {
                    if let onTheMapStudents = OnTheMapNavigationBarHelper.sharedInstance().students {
                        var onTheMapSet = Set(onTheMapStudents)
                        if (onTheMapSet.contains(student!)) {
                            onTheMapSet.remove(student!)
                        }
                        var result = Array(onTheMapSet)
                        result.append(student!)
                        result.sortInPlace() { one, other in
                            return one.updatedAt!.compare(other.updatedAt!) == NSComparisonResult.OrderedDescending
                        }
                        OnTheMapNavigationBarHelper.sharedInstance().students = result
                    } else {
                        OnTheMapNavigationBarHelper.sharedInstance().students = [student!]
                    }
                    delegate.didUpdateData(true, errorString: nil)
                } else {
                    delegate.didUpdateData(false, errorString: errorString)
                }
            }
        } else {
            self.createStudentLocation(studentLocation) { success, student, errorString in
                if (success) {
                    if var onTheMapStudents = OnTheMapNavigationBarHelper.sharedInstance().students {
                        onTheMapStudents.append(student!)
                        onTheMapStudents.sortInPlace() { one, other in
                            return one.updatedAt!.compare(other.updatedAt!) == NSComparisonResult.OrderedDescending
                        }
                    }
                    delegate.didUpdateData(true, errorString: nil)
                } else {
                    delegate.didUpdateData(false, errorString: errorString)
                }
            }
        }
    }
    
    public func getStudentLocationsWithDelegate(delegate:StudentDataDelegate) {
        delegate.doRefresh()
        _ = OnTheMapNavigationBarHelper.sharedInstance().getStudentsSize()
        self.getStudentLocations(skip) { success, students, errorString in
            if (success) {
                self.skip += 1
                if let onTheMapStudents = OnTheMapNavigationBarHelper.sharedInstance().students {
                    let onTheMapSet = Set(onTheMapStudents)
                    if let resultStudents = students {
                        var resultSet = Set(resultStudents)
                        resultSet.subtractInPlace(onTheMapSet)
                        var result = Array(resultSet)
                        result.sortInPlace() { one, other in
                            return one.updatedAt!.compare(other.updatedAt!) == NSComparisonResult.OrderedDescending
                        }
                        OnTheMapNavigationBarHelper.sharedInstance().students = onTheMapStudents + result
                    }
                } else {
                    if let resultStudents = students {
                        let resultSet = Set(resultStudents)
                        var result = Array(resultSet)
                        result.sortInPlace() { one, other in
                            return one.updatedAt!.compare(other.updatedAt!) == NSComparisonResult.OrderedDescending
                        }
                        OnTheMapNavigationBarHelper.sharedInstance().students = result
                    }
                    
                }
                if (DEBUG) {
                    print(OnTheMapNavigationBarHelper.sharedInstance().students?.count)
                }
                delegate.didRefresh(success, errorString: errorString)
            } else {
                delegate.didRefresh(false, errorString: errorString)
            }
        }
    }
    
    public func getStudentLocations(skip:Int, completionHandler: (success:Bool, students:[StudentLocation]?, errorString:String?) -> Void) -> NSURLSessionDataTask {
        var parameters = [
            ParseClient.MethodParameters.Limit : "100"
        ]
        if (skip > 0) {
            parameters[ParseClient.MethodParameters.Skip] = "\(skip)"
        }
        let task = self.httpClient!.taskForGETMethod(ParseClient.Methods.StudentLocation, parameters: parameters) { JSONResult, error in
            if let _ = error {
                completionHandler(success: false, students: nil, errorString: "Fetch Students Location Error")
            } else {
                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String:AnyObject]] {
                    //filter the results and then map it to a student
                    let students = results.filter({((($0[ParseClient.StudendLocationKeys.Latitude] as? Float) != nil) && (($0[ParseClient.StudendLocationKeys.Longitude] as? Float) != nil))}).map({StudentLocation(student: $0)})
                    completionHandler(success: true, students: students, errorString: nil)
                } else {
                    completionHandler(success: false, students: nil, errorString: "Fetch Students Location Error")
                }
            }
        }
        
        return task
    }
    
    public func createStudentLocation(student:StudentLocation, completionHandler: (success:Bool, student:StudentLocation?, errorString:String?) -> Void) -> NSURLSessionDataTask {
        let task = self.httpClient!.taskForPOSTMethod(ParseClient.Methods.StudentLocation, parameters: [String:AnyObject](), jsonBody: student.toDictionary()) { JSONResult, error in
            if let _ = error {
                completionHandler(success: false, student: nil, errorString: "Create Student Location Error")
            } else {
                if let _ = JSONResult.valueForKey(ParseClient.StudendLocationKeys.ObjectID) as? String {
                    if let _ = JSONResult.valueForKey(ParseClient.StudendLocationKeys.CreatedAt) as? String {
                        completionHandler(success: true, student: StudentLocation(student: JSONResult as! [String:AnyObject]), errorString: nil)
                    } else {
                        completionHandler(success: false, student: nil, errorString: "Create Student Location Error")
                    }
                } else {
                    if let error = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Error) as? String {
                        completionHandler(success: false, student: nil, errorString: error)
                    }
                    completionHandler(success: false, student: nil, errorString: "Create Student Location Error")
                }
            }
        }
        return task
    }
    
    public func updateStudentLocation(student:StudentLocation, completionHandler: (success:Bool, student:StudentLocation?, errorString:String?) -> Void) -> NSURLSessionDataTask {
        let method = HTTPClient.substituteKeyInMethod(ParseClient.Methods.StudentLocationWithID, key: "id", value: student.objectId!)
        let task = self.httpClient!.taskForPUTMethod(method!, parameters: [String:AnyObject](), jsonBody: student.toDictionary()) { JSONResult, error in
            if let _ = error {
                completionHandler(success: false, student: nil, errorString: "Update Student Location Error")
            } else {
                if let updatedAt = JSONResult.valueForKey(ParseClient.StudendLocationKeys.UpdateAt) as? String {
                    student.setStudentUpdatedAt(updatedAt)
                    completionHandler(success: true, student: student, errorString: nil)
                } else {
                    if let error = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Error) as? String {
                        completionHandler(success: false, student: nil, errorString: error)
                    }
                    completionHandler(success: false, student: nil, errorString: "Update Student Location Error")
                }
            }
        }
        
        return task;
    }
    
    public func searchStudentByKey(uniqueKey:String, completionHandler: (success:Bool, student:StudentLocation?, errorString:String?) -> Void) -> NSURLSessionDataTask {
        let search = [
            ParseClient.StudendLocationKeys.UniqueKey : uniqueKey
        ]
        let data: NSData?
        do {
            data = try NSJSONSerialization.dataWithJSONObject(search, options: [])
        } catch {
            data = nil
        }
        let parameters:[String:AnyObject] = [
            ParseClient.MethodParameters.Where : NSString(data: data!, encoding: NSUTF8StringEncoding)!
        ]
        let task = self.httpClient!.taskForGETMethod(ParseClient.Methods.StudentLocation, parameters: parameters) { JSONResult, error in
            if let _ = error {
                completionHandler(success: false, student: nil, errorString: "Error searching for user")
            } else {
                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String: AnyObject]] {
                    if (results.isEmpty) {
                        completionHandler(success: false, student: nil, errorString: "Student Location Not Found Error")
                    } else {
                        completionHandler(success: true, student: StudentLocation(student: results[0]), errorString: nil)
                    }
                } else {
                    completionHandler(success: false, student: nil, errorString: "Student Location Not Found Error")
                }
            }
        }
        
        return task;
    }
}
