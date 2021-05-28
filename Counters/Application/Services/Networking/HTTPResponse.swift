//
//  HTTPResponse.swift
//  Counters
//
//  Created by Javier Cala Uribe on 24/5/21.
//

import Foundation

// Counters Request Tpype
enum RequestType {
    case getAllCounters, addCounter, incCounter, decCounter, delCounter
}

class HTTPResponse {

    // MARK: - Functions

    // Check Response from Server
    class func checkResponse(_ requestType:RequestType, onCompletion:@escaping (_ isSuccess: Bool, _ countersArray:[CNApiCounters], _ error: Error?) -> Void) -> (Data?, URLResponse?, Error?) -> Void {

        let completionResponse: (Data?, URLResponse?, Error?) -> Void = ({(data, response, error) in

            // Check error with URLSession request
            guard error == nil else {
                callResponseWith(requestType, isResponseSuccess:false, withData:data, withError:error, statusCode:nil, onCompletion:onCompletion)
                return
            }

            //Logger("Response: data:\(data) \nresponse:\(response) \nerror:\(error)")
            //Logger("Data:"+String(decoding: data!, as: UTF8.self))
            
            let httpURLResponse = response as! HTTPURLResponse
            let code            = httpURLResponse.statusCode
            let success         = (200...299 ~= code) ? true : false

            callResponseWith(requestType, isResponseSuccess:success, withData:data, withError:error, statusCode:code, onCompletion:onCompletion)
        })
        
        return completionResponse
    }

    // Check Request Type
    class func callResponseWith(_ requestType:RequestType, isResponseSuccess:Bool, withData data:Data?, withError error:Error?, statusCode code:Int?, onCompletion:(_ isSuccess:Bool, _ countersArray:[CNApiCounters], _ error: Error?) -> Void) {
        
        guard isResponseSuccess else {
            onCompletion(isResponseSuccess, [CNApiCounters](), error)
            return
        }
        // Is success
        do {
            guard let dataResponse = data else {
                return
            }
            let decoder = JSONDecoder()
            let jsonArray = try decoder.decode([CNApiCounters].self, from: dataResponse)
            CNCoreData.sharedInstance.setCNCounters(jsonArray)
            onCompletion(isResponseSuccess, jsonArray, error)
            return
            
        } catch let error {
            Logger("json counter error: \(error.localizedDescription)")
        }

        onCompletion(isResponseSuccess, [CNApiCounters](), error)
    }
}
