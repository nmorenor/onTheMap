import Quick
import Nimble
import On_The_Map

let userName = "your@mail.com"
let password = "yourPassword"
let badPassword = "badPass"

class UdacityClientTests: QuickSpec {
    
    struct ResponseData {
        var success:Bool
        var session:UdacitySession?
        var userData:UdacityUserData?
        var studentLocations:[StudentLocation]?
        var studentLocation:StudentLocation?
        var error:String?
        
        init(success:Bool, result:UdacitySession?, error:String?) {
            self.success = success
            self.session = result
            self.error = error
        }
        
        init(success:Bool, result:UdacityUserData?, error:String?) {
            self.success = success
            self.userData = result
            self.error = error
        }
        
        init(success:Bool, result:[StudentLocation]?, error:String?) {
            self.success = success
            self.studentLocations = result
            self.error = error
        }
        
        init(success:Bool, result:StudentLocation?, error:String?) {
            self.success = success
            self.studentLocation = result
            self.error = error
        }
    }
    
    class FacebookLoginTestDelegate: NSObject, UdacitySessionDelegate {
        
        var complete:Bool = false
        var error:Bool = false
        
        override init() {
            super.init()
        }
        
        func loginDidComplete(button:UIButton) {
            self.complete = true
        }
        
        func loginDidCompleteWithError(error:String, retry:Bool, button:UIButton) {
            self.complete = true
            self.error = true
        }
    }
    
    override func spec() {
        describe("shared client instance") {
            var udacityClient:UdacityClient!
            beforeEach {
                udacityClient = UdacityClient.sharedInstance()
            }
            
            it("is not nil") {
                expect(udacityClient).toNot(beNil())
            }
        }
        
        describe("udacity client api") {
            var udacityClient:UdacityClient!
            beforeEach {
                udacityClient = UdacityClient.sharedInstance()
            }
            
            it("is not able to login") {
                let login = self.tryLogin(userName, password: badPassword, udacityClient: udacityClient)
                
                expect(login.success).to(beFalse())
                expect(login.error).toNot(beNil())
                expect(login.session).to(beNil())
            }
            
            it("is able to login") {
                let login = self.tryLogin(userName, password: password, udacityClient: udacityClient)
                
                expect(login.success).to(beTrue())
                expect(login.error).to(beNil())
                expect(login.session).toNot(beNil())
            }
        }
        
        describe("udacity user data") {
            var udacityClient:UdacityClient!
            beforeEach {
                udacityClient = UdacityClient.sharedInstance()
            }
            
            it("is able to get data logged in") {
                let session = udacityClient.udacitySession
                
                expect(session).toNot(beNil())
                expect(session!.userID).toNot(beNil())
                
                var responseData:ResponseData! = nil
                let task = udacityClient.getUserData(session!.userID!) { success, userData, errorString in
                    responseData = ResponseData(success: success, result: userData, error: errorString)
                }
                
                //wait for a response
                while (task.state != NSURLSessionTaskState.Completed || responseData == nil) {
                    sleep(2)
                }
                
                expect(responseData.success).to(beTrue())
                expect(responseData.error).to(beNil())
                expect(responseData.userData).toNot(beNil())
            }
        }
        
        describe("Parse client shared instance") {
            var parseClient:ParseClient!
            beforeEach {
                parseClient = ParseClient.sharedInstance()
            }
            
            it("is not nil") {
                expect(parseClient).toNot(beNil())
            }
        }
        
        describe("Parse client Get Students") {
            var parseClient:ParseClient!
            beforeEach {
                parseClient = ParseClient.sharedInstance()
            }
            
            it("can fetch student locations") {
                var responseData:ResponseData!
                
                let task = parseClient.getStudentLocations(0) { success, userData, errorString in
                    responseData = ResponseData(success: success, result: userData, error: errorString)
                }
                
                //wait for a response
                while (task.state != NSURLSessionTaskState.Completed || responseData == nil) {
                    sleep(2)
                }
                
                expect(responseData.success).to(beTrue())
                expect(responseData.error).to(beNil())
                expect(responseData.studentLocations).toNot(beNil())
                expect(responseData.studentLocations).toNot(beEmpty())
            }
        }
        
        describe("can create-update-fetch student") {
            var parseClient:ParseClient!
            var udacityClient:UdacityClient!
            beforeEach {
                parseClient = ParseClient.sharedInstance()
                udacityClient = UdacityClient.sharedInstance()
            }
        
            it("can search student") {
                
                expect(udacityClient.userData).toNot(beNil())
                
                var responseData:ResponseData? = nil
                let uniqueKey = "\(udacityClient.userData!.id!)"
                var task = parseClient.searchStudentByKey(uniqueKey) { success, studentLocation, errorString in
                    responseData = ResponseData(success: success, result: studentLocation, error: errorString)
                }
                
                //wait for a response
                while (task.state != NSURLSessionTaskState.Completed || responseData == nil) {
                    sleep(2)
                }
                
                var student:StudentLocation?
                if (responseData != nil && responseData!.success) {
                    var updateStudentResponseData:ResponseData!
                    student = responseData!.studentLocation
                    student!.lastName = "Moreno Rangel"
                    
                    let updateStudentTask = parseClient.updateStudentLocation(student!) { success, studentLocation, errorString in
                        updateStudentResponseData = ResponseData(success: success, result: studentLocation, error: errorString)
                    }
                    
                    //wait for a response
                    while (updateStudentTask.state != NSURLSessionTaskState.Completed || updateStudentResponseData == nil) {
                        sleep(2)
                    }
                    
                    expect(updateStudentResponseData.success).to(beTrue())
                    expect(updateStudentResponseData.error).to(beNil())
                    expect(updateStudentResponseData.studentLocation).toNot(beNil())
                    
                } else {
                    var createStudentResponseData:ResponseData!
                    var params:[String:AnyObject]
                    
                    student = StudentLocation(uniquekey: uniqueKey)
                    student!.firstName = "Ignacio"
                    student!.lastName = "Moreno"
                    student!.longitude = -105.224302
                    student!.latitude = 20.645168
                    student!.mapString = "Puerto Vallarta"
                    student!.mediaURL = NSURL(string: "https://www.github.com/nmorenor")!
                    let createStudentTask = parseClient.createStudentLocation(student!) { success, studentLocation, errorString in
                        createStudentResponseData = ResponseData(success: success, result: studentLocation, error: errorString)
                    }
                    
                    //wait for a response
                    while (createStudentTask.state != NSURLSessionTaskState.Completed || createStudentResponseData == nil) {
                        sleep(2)
                    }
                    
                    expect(createStudentResponseData.success).to(beTrue())
                    expect(createStudentResponseData.error).to(beNil())
                    expect(createStudentResponseData.studentLocation).toNot(beNil())
                    
                    //search it again
                    responseData = nil
                    var task = parseClient.searchStudentByKey(uniqueKey) { success, studentLocation, errorString in
                        responseData = ResponseData(success: success, result: studentLocation, error: errorString)
                    }
                    
                    //wait for a response
                    while (task.state != NSURLSessionTaskState.Completed || responseData == nil) {
                        sleep(2)
                    }
                    
                    expect(responseData!.success).to(beTrue())
                    expect(responseData!.error).to(beNil())
                    expect(responseData!.studentLocation).toNot(beNil())
                }
            }
        }
    
    }
    
    func tryLogin(user:String, password:String, udacityClient:UdacityClient) -> ResponseData {
        var login:ResponseData! = nil
        let task = udacityClient.getSessionID(user, password: password) { succes, session, errorString in
            login = ResponseData(success: succes, result: session, error: errorString)
        }
        
        //wait for a response
        while (task.state != NSURLSessionTaskState.Completed || login == nil) {
            sleep(2)
        }
        return login;
    }
}
