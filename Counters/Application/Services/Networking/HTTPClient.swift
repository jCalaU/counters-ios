//
//  HTTPClient.swift
//  Counters
//
//  Created by Javier Cala Uribe on 24/5/21.
//

import Foundation
import UIKit

class HTTPClient : NSObject, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    // MARK: - Properties
    
    static let sharedInstance = HTTPClient()
    
    // TimeoutInterval for URLRequest
    let timeoutIntervalRequest: Double = 30.0
            
    // Array for receive data : (session : Data)
    var requestData              = [URLSession : Data]()

    // Array for onCompletion request : (session : onCompletion)
    var requestCompletionHandler = [URLSession : ((Data?, URLResponse?, Error?) -> Void)]()
    
    // Define UserAgent
    var userAgent : String {
        let systemVersion = UIDevice.current.systemVersion
        let appVersion    = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        return "Counters/\(appVersion) (iOS \(systemVersion))"
    }
    
    // MARK: - Initialization
    
    fileprivate override init() {
    }

    // MARK: - Private Implementation
    
    // Define URLSessionConfiguration
    func getSessionConfig() -> URLSessionConfiguration {
        
        let sessionConfig = URLSessionConfiguration.default
        let additionalHeader :[AnyHashable: Any] = [UserAgent : userAgent, ContentType : JSONContentType]        
        sessionConfig.httpAdditionalHeaders = additionalHeader
        
        return sessionConfig
    }
    
    // Requests to Server
    func userRequestToServer(_ params: [String: Any]?, httpMethod: String, endPoint: String, onCompletion:@escaping (_ dataRequest: Data?, _ responseRequest:URLResponse?, _ error:Error?)->Void) {
                
        // Set session Config
        let sessionConfig   = getSessionConfig()
        let session         = URLSession(configuration:sessionConfig, delegate:self, delegateQueue:nil)
        
        // Set Endpoint
        guard let requestURL = URL(string: baseURL + apiVersion + endPoint) else {
            return
        }

        var request = URLRequest(url:requestURL)
        request.timeoutInterval = timeoutIntervalRequest
        
        // Set params
        if let parameters = params {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options:JSONSerialization.WritingOptions.prettyPrinted)
            } catch let error as NSError{
                Logger("params error: \(error.localizedDescription)")
            }
        }

        request.httpMethod  = httpMethod
        
        // Add onCompletion to array
        requestCompletionHandler.updateValue(onCompletion, forKey: session)
        
        // Prepare request
        sendRequest(session, request: request)
    }
    
    // Prepare URLSessionDataTask
    func sendRequest(_ session: URLSession, request: URLRequest) {
        let task = session.dataTask(with: request)
        // Send Request
        task.resume()
    }
            
    // MARK: - URLSession Delegates
    
    // URLSessionTaskDelegate : didCompleteWithError
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        DispatchQueue.main.async {
            // Go to completionHandler
            if let onCompletion = self.requestCompletionHandler[session] {
                onCompletion(self.requestData[session], task.response, error)
            }
            // Delete value for sessionKey
            self.requestData.removeValue(forKey:session)
            self.requestCompletionHandler.removeValue(forKey:session)
            
            // Cancel session
            session.invalidateAndCancel()
        }
    }
    
    // URLSessionDataDelegate : dataTask didReceive Data
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {

        // Save Data on array
        DispatchQueue.main.async {
            
            if let stream = self.requestData[session] {
                var d = Data()
                d.append(stream)
                d.append(data)
                self.requestData.updateValue(d, forKey: session)
            } else {
                self.requestData.updateValue(data, forKey: session)
            }
        }
    }
    
    // URLSessionDataDelegate : dataTask didReceive Response
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
    }
    
    // URLSessionDelegate didReceive challenge
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {return}
        completionHandler(
            .useCredential,
            URLCredential(trust: serverTrust)
        )
    }
}
