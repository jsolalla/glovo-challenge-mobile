//
//  APIEndpointConfig.swift
//  GlovoChallenge
//
//  Created by Jesus Santa Olalla on 7/9/18.
//  Copyright © 2018 Jesus Santa Olalla. All rights reserved.
//

import Foundation

public enum APIEndPointConfig: String, Equatable {
    
    case production = "http://192.168.15.167:3000"
    case development = "http://localhost:3000"
    
    private static let defaultConfig = APIEndPointConfig.development
    
    /// Get current server host value
    public static var current: APIEndPointConfig {
        return defaultConfig
    }
    
}
