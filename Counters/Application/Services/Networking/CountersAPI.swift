//
//  CountersAPI.swift
//  Counters
//
//  Created by Javier Cala Uribe on 24/5/21.
//

import Foundation

// Definition of URLs
#if DEBUG
    public let baseURL              : String = "http://127.0.0.1:3000"
    public let apiVersion           : String = "/api/v1"
#else
    public let baseURL              : String = "http://127.0.0.1:3000"
    public let apiVersion           : String = "/api/v1"
#endif

// Http method definitions
public enum Method: String {
    case GET, POST, PUT, DELETE
}

public let CountersErrorDomain      : NSErrorDomain = "counters.network.error.domain"
public let UserAgent                : String = "User-Agent"
public let ContentType              : String = "Content-Type"
public let JSONContentType          : String = "application/json"

// Endpoint for Counters
public let getCountersEndpoint      : String = "/counters"
public let addCounterEndpoint       : String = "/counter"
public let incCounterEndpoint       : String = "/counter/inc"
public let decCounterEndpoint       : String = "/counter/dec"

// Struct CNCounters
struct CNApiCounters: Codable {
    let count: Int64
    let id: String
    let title: String
}

enum CountersErrorCode : Int64 {
    case CountersErrorCodeNoData = -777
}
