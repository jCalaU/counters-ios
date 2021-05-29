//
//  CountersAPITests.swift
//  CountersTests
//
//  Created by Javier Cala Uribe on 29/5/21.
//

import XCTest
@testable import Counters

class CountersAPITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetAllCounters() throws {
        let expectation     = self.expectation(description: "Expecta Test: Get all counters")
        
        let completion = HTTPResponse.checkResponse(.getAllCounters, onCompletion: {(isSuccess: Bool, countersArray: [CNApiCounters], error: Error?) in
            
            XCTAssertTrue(isSuccess)
            expectation.fulfill()
        })

        HTTPClient.sharedInstance.userRequestToServer(nil,
                                                      httpMethod: Method.GET.rawValue,
                                                      endPoint: getCountersEndpoint,
                                                      onCompletion:completion)
     
        self.waitForExpectations(timeout: 15, handler:nil)
    }

    func testDeleteCounter() throws {
        let expectation     = self.expectation(description: "Expecta Test: Delete counter")
        
        let params:[String: Any] = ["id" : "t3st"]
                
        let completion = HTTPResponse.checkResponse(.delCounter, onCompletion:{( isSuccess:Bool, countersArray:[CNApiCounters], error: Error?) in

            XCTAssertTrue(isSuccess)
            expectation.fulfill()
        })

        HTTPClient.sharedInstance.userRequestToServer(params,
                                                      httpMethod: Method.DELETE.rawValue,
                                                      endPoint: addCounterEndpoint,
                                                      onCompletion:completion)
     
        self.waitForExpectations(timeout: 15, handler:nil)
    }

    func testAddCounter() throws {
        let expectation     = self.expectation(description: "Expecta Test: Add counter")
        
        let params:[String: Any] = [
            "title"       : "t1tl3"]
                
        // Start request
        let completion = HTTPResponse.checkResponse(.addCounter, onCompletion:{( isSuccess:Bool, countersArray:[CNApiCounters], error: Error?) in

            XCTAssertTrue(isSuccess)
            expectation.fulfill()
        })
        
        HTTPClient.sharedInstance.userRequestToServer(params,
                                                      httpMethod: Method.POST.rawValue,
                                                      endPoint: addCounterEndpoint,
                                                      onCompletion:completion)
     
        self.waitForExpectations(timeout: 15, handler:nil)
    }
    
    func testIncreaseCounter() throws {
        let expectation     = self.expectation(description: "Expecta Test: Increase counter")
                
        let params:[String: Any] = [
            "title"       : "t1tl3_inc"]
        
        // Start request
        let completion = HTTPResponse.checkResponse(.addCounter, onCompletion:{( isSuccess:Bool, countersArray:[CNApiCounters], error: Error?) in

            guard let id = countersArray.first?.id else { return }
            
            let params:[String: Any] = [
                "id" : id]
            
            let completion = HTTPResponse.checkResponse(.incCounter, onCompletion:{( isSuccess:Bool, countersArray:[CNApiCounters], error: Error?) in

                XCTAssertTrue(isSuccess)
                expectation.fulfill()
            })

            HTTPClient.sharedInstance.userRequestToServer(params,
                                                          httpMethod: Method.POST.rawValue,
                                                          endPoint: incCounterEndpoint,
                                                          onCompletion:completion)
        })
        
        HTTPClient.sharedInstance.userRequestToServer(params,
                                                      httpMethod: Method.POST.rawValue,
                                                      endPoint: addCounterEndpoint,
                                                      onCompletion:completion)
     
        self.waitForExpectations(timeout: 15, handler:nil)
    }
    
    func testDecreaseCounter() throws {
        let expectation     = self.expectation(description: "Expecta Test: Decrease counter")
                
        let params:[String: Any] = [
            "title"       : "t1tl3_dec"]
        
        // Start request
        let completion = HTTPResponse.checkResponse(.addCounter, onCompletion:{( isSuccess:Bool, countersArray:[CNApiCounters], error: Error?) in

            guard let id = countersArray.first?.id else { return }
            
            let params:[String: Any] = [
                "id" : id]
            
            let completion = HTTPResponse.checkResponse(.decCounter, onCompletion:{( isSuccess:Bool, countersArray:[CNApiCounters], error: Error?) in

                XCTAssertTrue(isSuccess)
                expectation.fulfill()
            })

            HTTPClient.sharedInstance.userRequestToServer(params,
                                                          httpMethod: Method.POST.rawValue,
                                                          endPoint: decCounterEndpoint,
                                                          onCompletion:completion)
        })
        
        HTTPClient.sharedInstance.userRequestToServer(params,
                                                      httpMethod: Method.POST.rawValue,
                                                      endPoint: addCounterEndpoint,
                                                      onCompletion:completion)
     
        self.waitForExpectations(timeout: 15, handler:nil)
    }

}
