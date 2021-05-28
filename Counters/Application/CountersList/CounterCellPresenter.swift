//
//  CounterCellPresenter.swift
//  Counters
//
//  Created by Javier Cala Uribe on 25/5/21.
//

import Foundation

protocol CounterCellPresenterDelegate {
    func reloadTableView()
    func showErrorMessage(_ title:String, _ error:Error?, _ retryAction: @escaping (() -> Void))
}

final class CounterCellPresenter {
    
    let countersdb : CNCounters
    var delegate: CounterCellPresenterDelegate?
    
    init(_ counter: CNCounters) {
        countersdb = counter
    }
    
    func requestCounterIncrease() {
        requestCounterChange(incCounterEndpoint, requestType: .incCounter)
    }
    
    func requestCounterDecrease() {
        requestCounterChange(decCounterEndpoint, requestType: .decCounter)
    }
    
    func requestCounterChange(_ endpoint: String, requestType: RequestType ) {

        guard let counterId = countersdb.id else { return }
        
        let params:[String: Any] = [
            "id" : counterId]
        
        let completion = HTTPResponse.checkResponse(requestType, onCompletion:{( isSuccess:Bool, countersArray:[CNApiCounters], error: Error?) in
            
            guard isSuccess else {
                // Error
                guard let text = self.countersdb.title else { return }
                let nextCount = self.countersdb.count + 1
                let title = String(format: "COUNTERSLIST_FAIL_UPDATE_MESSAGE".localized, text, nextCount)
                let retryAction = (requestType == .incCounter) ? self.requestCounterIncrease : self.requestCounterDecrease
                self.delegate?.showErrorMessage(title, error, retryAction)

                return
            }
            // Success
            self.delegate?.reloadTableView()
        })

        HTTPClient.sharedInstance.userRequestToServer(params,
                                                      httpMethod: Method.POST.rawValue,
                                                      endPoint: endpoint,
                                                      onCompletion:completion)
    }
}
