//
//  APIEndpointConfig.swift
//  GlovoChallenge
//
//  Created by Jesus Santa Olalla  (Vendor) on 7/9/18.
//  Copyright © 2018 Jesus Santa Olalla. All rights reserved.
//

import Foundation

public enum APIEndPointConfig: String, Equatable {
    
    case production = "http://192.168.100.15:3000"
    case development = "http://localhost:3000"
    
    private static let defaultConfig = APIEndPointConfig.production
    
    /// Get current server host value
    public static var current: APIEndPointConfig {
        return defaultConfig
    }
    
}
