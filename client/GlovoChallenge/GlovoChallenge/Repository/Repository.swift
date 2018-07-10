//
//  Repository.swift
//  GlovoChallenge
//
//  Created by Jesus Santa Olalla on 7/9/18.
//  Copyright © 2018 Jesus Santa Olalla. All rights reserved.
//

import Foundation
import ReactiveKit
import Alamofire

enum GlovoRepositoryError: Error {
    case failure
    case missingData
}

protocol GlovoRepository {
    func getCountries() -> Signal<[Country], GlovoRepositoryError>
    func getCities() -> Signal<[City], GlovoRepositoryError>
    func getCity(with id: String) -> Signal<City, GlovoRepositoryError>
}

class Repository: GlovoRepository {
    
    /// Creates a `Signal` with an array of countries.
    func getCountries() -> Signal<[Country], GlovoRepositoryError> {
        
        return Signal { observer in
            
            let task = Alamofire.request(GlovoEndpoint.countries.path).responseData { response in
                
                switch response.result {
                case .success(let responseData):
                    
                    guard let countries = try? JSONDecoder().decode([Country].self, from: responseData) else {
                        observer.failed(.missingData)
                        return
                    }
                    
                    observer.next(countries)
                    observer.completed()
                    
                case .failure(_):
                    observer.failed(.failure)
                }
                
            }
            
            return BlockDisposable {
                task.cancel()
            }
        }
        
    }
    
    /// Creates a `Signal` with an array of cities and their correspondig working areas.
    func getCities() -> Signal<[City], GlovoRepositoryError> {
        
        return Signal { observer in
            
            let task = Alamofire.request(GlovoEndpoint.cities.path).responseData { response in
                
                switch response.result {
                case .success(let responseData):
                    
                    guard let cities = try? JSONDecoder().decode([City].self, from: responseData) else {
                        observer.failed(.missingData)
                        return
                    }
                    
                    observer.next(cities)
                    observer.completed()
                    
                case .failure(_):
                    observer.failed(.failure)
                }
                
            }
            
            return BlockDisposable {
                task.cancel()
            }
        }
        
    }
    
    /// Creates a `Signal` with a detailed city.
    func getCity(with id: String) -> Signal<City, GlovoRepositoryError> {
        
        return Signal { observer in
           
            let task = Alamofire.request(GlovoEndpoint.city(cityCode: id).path).responseData { response in
                
                switch response.result {
                case .success(let responseData):
                    
                    guard let city = try? JSONDecoder().decode(City.self, from: responseData) else {
                        observer.failed(.missingData)
                        return
                    }
                    
                    observer.next(city)
                    observer.completed()
                    
                case .failure(_):
                    observer.failed(.failure)
                }
                
            }
            
            return BlockDisposable {
                task.cancel()
            }
        }
        
    }
    
}
