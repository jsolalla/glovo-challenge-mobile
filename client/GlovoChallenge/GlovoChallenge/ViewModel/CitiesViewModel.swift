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
    let userSelectedCity = Subject<GMSMarker, NoError>()
    let currentLocation = Subject<CLLocation, NoError>()
    
    var polygons: [GMSPolygon] = []
    var markers: [GMSMarker] = []
    
    init() {
        
        combineLatest(glovoRepository.getCountries(), glovoRepository.getCities()).observeNext { [weak self] countries, cities in
            self?.countries = countries
            self?.cities = cities
            self?.setMap()
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
    
    private func setMap() {
        
        for city in cities {
            
            var newPolygone: GMSPolygon!
            var cityCoordinates: [CLLocationCoordinate2D] = []
            
            for workingArea in city.working_area {
                if let path = GMSMutablePath(fromEncodedPath: workingArea) {
                    
                    for location in 0..<path.count() {
                        cityCoordinates.append(path.coordinate(at: location))
                    }
                    
                    newPolygone = GMSPolygon(path: path)
                    newPolygone.fillColor = UIColor(red: 255, green: 255, blue: 0, alpha: 0.6)
                    polygon.next(newPolygone)
                    polygons.append(newPolygone)
                }
            }
            
            let centerLocation = getCenterLocation(for: cityCoordinates)
            let newMarker = GMSMarker(position: centerLocation)
            newMarker.icon = UIImage(named: "glovo_marker")
            newMarker.title = city.code
            marker.next(newMarker)
            markers.append(newMarker)
        }
        
    }
    
    private func getCenterLocation(for coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        
        let latitudes = coordinates.map { $0.latitude }.sorted()
        let longitudes = coordinates.map { $0.longitude }.sorted()
        
        let maxLatitude: CLLocationDegrees = latitudes.last ?? 0.0
        let minLatitude: CLLocationDegrees = latitudes.first ?? 0.0
        let maxLongitude: CLLocationDegrees = longitudes.last ?? 0.0
        let minLongitude: CLLocationDegrees = longitudes.first ?? 0.0
        
        return CLLocationCoordinate2D(latitude: (maxLatitude + minLatitude) / 2, longitude: (maxLongitude + minLongitude) / 2)
    }
    
    private func getCityDetail(_ city: City) {
        glovoRepository.getCity(with: city.code).observeNext { [weak self] city in
            self?.selectedCity.next(city)
        }.dispose(in: disposeBag)
    }
    
    func setUserSelectedCity(_ city: City) {
        if let marker = markers.filter ({ $0.title!.elementsEqual(city.code)}).first {
            selectedCityName.next(city.name)
            userSelectedCity.next(marker)
        }
    }
    
    func getCountries() -> [Country] {
        return countries
    }
    
    func getCities(for country: Country) -> [City] {
        return cities.filter { $0.country_code.elementsEqual(country.code) }
    }
    
}
