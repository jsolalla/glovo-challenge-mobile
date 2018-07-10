//
//  GlovoEndpoint.swift
//  GlovoChallenge
//
//  Created by Jesus Santa Olalla on 7/9/18.
//  Copyright © 2018 Jesus Santa Olalla. All rights reserved.
//

import Foundation

enum GlovoEndpoint {
    case countries
    case cities
    case city(cityCode: String)
}


extension GlovoEndpoint {
    
    public var path: String {
        switch self {
        case .countries:
            return "\(APIEndPointConfig.current.rawValue)/api/countries"
        case .cities:
            return "\(APIEndPointConfig.current.rawValue)/api/cities"
        case .city(let cityCode):
            return "\(APIEndPointConfig.current.rawValue)/api/cities/\(cityCode)"
        }
    }
    
}
