//
//  CitiesViewModel.swift
//  GlovoChallenge
//
//  Created by Jesus Santa Olalla  (Vendor) on 7/9/18.
//  Copyright © 2018 Jesus Santa Olalla. All rights reserved.
//

import Foundation
import ReactiveKit
import GoogleMaps

class CitiesViewModel {
    
    private let glovoRepository: GlovoRepository = Repository()
    private let disposeBag = DisposeBag()
    
    private var cities: [City] = []
    private var countries: [Country] = []
    
    let polygon = Subject<GMSPolygon, NoError>()
    let marker = Subject<GMSMarker, NoError>()
    let selectedCityName = Subject<String, NoError>()
    let selectedCity = Subject<City?, NoError>()
    let currentLocation = Subject<CLLocation, NoError>()
    
    var polygons: [GMSPolygon] = []
    var markers: [GMSMarker] = []
    
    init() {
        
        combineLatest(glovoRepository.getCountries(), glovoRepository.getCities()).observeNext { [weak self] countries, cities in
            self?.countries = countries
            self?.cities = cities
            self?.setPolygons()
        }.dispose(in: disposeBag)
        
        currentLocation.observeNext { [weak self] location in
            
            guard let strongSelf = self else {
                return
            }
            
            for city in strongSelf.cities {
                for workingArea in city.working_area {
                    if let path = GMSMutablePath(fromEncodedPath: workingArea) {
                        if GMSGeometryContainsLocation(location.coordinate, path, false) {
                            strongSelf.selectedCityName.next(city.name)
                            strongSelf.getCityDetail(city)
                        }
                    }
                }
            }
            
        }.dispose(in: disposeBag)
        
    }
    
    private func setPolygons() {
        
        for city in cities {
            
            var newPolygone: GMSPolygon!
            
            for workingArea in city.working_area {
                let path = GMSMutablePath(fromEncodedPath: workingArea)
                newPolygone = GMSPolygon(path: path)
                newPolygone.fillColor = UIColor(red: 255, green: 255, blue: 0, alpha: 0.6)
                polygon.next(newPolygone)
                polygons.append(newPolygone)
            }
            
            
            let newMarker = GMSMarker(position: newPolygone.path!.coordinate(at: 0))
            marker.next(newMarker)
            markers.append(newMarker)
        }
        
    }
    
    private func getCityDetail(_ city: City) {
        glovoRepository.getCity(with: city.code).observeNext { [weak self] city in
            self?.selectedCity.next(city)
        }.dispose(in: disposeBag)
    }
    
}
