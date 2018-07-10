//
//  CitiesViewController.swift
//  GlovoChallenge
//
//  Created by Jesus Santa Olalla  (Vendor) on 7/9/18.
//  Copyright © 2018 Jesus Santa Olalla. All rights reserved.
//

import UIKit
import GoogleMaps
import SnapKit
import ReactiveKit
import Bond

class CitiesViewController: UIViewController {

    let viewModel: CitiesViewModel = CitiesViewModel()
    let disposeBag = DisposeBag()
    let locationManager = CLLocationManager()
    
    lazy var mapView: GMSMapView = {
        let map = GMSMapView(frame: view.bounds)
        map.isMyLocationEnabled = true
        map.delegate = self
        return map
    }()
    
    lazy var cityDetailView: CityDetailView = {
        let cityDetail = CityDetailView()
        cityDetail.shown = false
        cityDetail.layer.cornerRadius = 12
        cityDetail.backgroundColor = .white
        cityDetail.layer.shadowColor = UIColor.black.cgColor
        cityDetail.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        cityDetail.layer.masksToBounds = false
        cityDetail.layer.shadowRadius = 10.0
        cityDetail.layer.shadowOpacity = 0.3
        return cityDetail
    }()
    
    lazy var btnSelectCity: UIButton = {
        let selectCity = UIButton()
        selectCity.backgroundColor = .white
        selectCity.layer.cornerRadius = 12
        selectCity.setTitleColor(view.tintColor, for: .normal)
        selectCity.setTitle("search for city...", for: .normal)
        selectCity.layer.shadowColor = UIColor.black.cgColor
        selectCity.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        selectCity.layer.masksToBounds = false
        selectCity.layer.shadowRadius = 10.0
        selectCity.layer.shadowOpacity = 0.3
        return selectCity
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch (CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        default:
            let defaultCoordinate = mapView.projection.coordinate(for: mapView.center)
            mapView.animate(toLocation: defaultCoordinate)
            mapView.animate(toZoom: 5)
        }
        
        setConstraints()
        setObservers()
    }

    func setObservers() {
        
        btnSelectCity.reactive.tap.observeNext {
            self.presentSelectCityViewController()
        }.dispose(in: disposeBag)
        
        viewModel.polygon.observeNext { [weak self] polygon in
            polygon.map = self?.mapView
        }.dispose(in: disposeBag)
        
        viewModel.polygon.observeNext { [weak self] polygon in
            polygon.map = self?.mapView
        }.dispose(in: disposeBag)
        
        viewModel.selectedCityName.observeNext { [weak self] cityName in
            self?.btnSelectCity.setTitle(cityName, for: .normal)
        }.dispose(in: disposeBag)
        
        viewModel.userSelectedCity.observeNext { [weak self] marker in
            self?.mapView.animate(toLocation: marker.position)
            self?.mapView.animate(toZoom: GlovoConstants.defaultZoom)
        }.dispose(in: disposeBag)
        
        viewModel.selectedCity.observeNext { [weak self] city in
            
            guard let city = city else {
                self?.btnSelectCity.setTitle("search for city...", for: .normal)
                self?.animateHideCityDetailView()
                return
            }
            
            self?.animateShowCityDetailView()
            self?.cityDetailView.lblCity.text = city.name
            self?.cityDetailView.lblCurrency.text = city.currency
            self?.cityDetailView.lblTimeZone.text = city.time_zone
            
        }.dispose(in: disposeBag)
        
    }
    
    func presentSelectCityViewController() {
        let selectCityViewController = SelectCityViewController()
        selectCityViewController.viewModel = self.viewModel
        let navigationController = UINavigationController(rootViewController: selectCityViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
}

// MARK: - CLLocationManagerDelegate

extension CitiesViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            mapView.animate(toLocation: location.coordinate)
            mapView.animate(toZoom: GlovoConstants.defaultZoom)
            viewModel.currentLocation.next(location)
        }
        
        locationManager.stopUpdatingLocation()
    }
    
}

// MARK: - GMSMapViewDelegate

extension CitiesViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        if position.zoom < 10 {
            
            mapView.clear()
            
            viewModel.selectedCity.next(nil)
            viewModel.markers.forEach { marker in
                marker.map = mapView
            }
            
        } else {
            
            mapView.clear()
            
            let center = position.target
            let newLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
            
            viewModel.currentLocation.next(newLocation)
            viewModel.polygons.forEach { polygon in
                polygon.map = mapView
            }
          
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.animate(toLocation: marker.position)
        mapView.animate(toZoom: GlovoConstants.defaultZoom)
        return true
    }
    
}

// MARK: - SnapKit

extension CitiesViewController {
    
    func setConstraints() {
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints { (maker) in
            maker.top.equalTo(view)
            maker.bottom.equalTo(view)
            maker.left.equalTo(view)
            maker.right.equalTo(view)
        }
        
        view.addSubview(btnSelectCity)
        btnSelectCity.snp.makeConstraints { (maker) in
            maker.top.equalTo(60)
            maker.left.right.equalTo(20)
            maker.width.equalToSuperview().inset(20)
            maker.height.equalTo(44)
        }
        
        view.addSubview(cityDetailView)
        cityDetailView.snp.makeConstraints { (maker) in
            maker.top.equalTo(view.frame.height)
            maker.left.right.equalTo(20)
            maker.width.equalToSuperview().inset(20)
            maker.height.equalTo(80)
        }
        
    }
    
    func animateShowCityDetailView() {
        
        if !cityDetailView.shown {
            
            cityDetailView.shown = true
            cityDetailView.snp.updateConstraints({ (maker) in
                maker.top.equalTo(view.frame.height).inset(view.frame.height - 120)
            })
            
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    func animateHideCityDetailView() {
        
        if cityDetailView.shown {
            
            cityDetailView.shown = false
            cityDetailView.snp.updateConstraints({ (maker) in
                maker.top.equalTo(view.frame.height)
            })
            
            UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
            
        }
        
    }
    
}
