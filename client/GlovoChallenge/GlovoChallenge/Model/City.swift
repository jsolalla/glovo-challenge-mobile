//
//  City.swift
//  GlovoChallenge
//
//  Created by Jesus Santa Olalla  (Vendor) on 7/9/18.
//  Copyright © 2018 Jesus Santa Olalla. All rights reserved.
//

import Foundation

struct City: Decodable {
    
    let working_area: [String]
    let code: String
    let name: String
    let country_code: String
    
    // Only on city detail response
    let time_zone: String?
    let enabled: Bool?
    let currency: String?
    let busy: Bool?
    let language_code: String?
    
}
