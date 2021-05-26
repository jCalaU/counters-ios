//
//  CounterCellPresenter.swift
//  Counters
//
//  Created by Javier Cala Uribe on 25/5/21.
//

import Foundation

protocol CounterCellPresenterDelegate {
    func reloadTableView()
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
        
        let completion = HTTPResponse.checkResponse(requestType, onCompletion:{( isSuccess:Bool, countersArray:[CNApiCounters]) in
            
            guard isSuccess else {
                // show message error
            return
            }
            self.delegate?.reloadTableView()
        })

        HTTPClient.sharedInstance.userRequestToServer(params,
                                                      httpMethod: Method.POST.rawValue,
                                                      endPoint: endpoint,
                                                      onCompletion:completion)
    }
}
