//
//  SelectCityViewController.swift
//  GlovoChallenge
//
//  Created by Jesus Santa Olalla  (Vendor) on 7/10/18.
//  Copyright © 2018 Jesus Santa Olalla. All rights reserved.
//

import UIKit
import ReactiveKit

class SelectCityViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    lazy var citiesTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    var viewModel: CitiesViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Select city"
        setConstraints()
    }

}

// MARK: - UITableViewDataSource

extension SelectCityViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getCountries().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let country = viewModel.getCountries()[section]
        let cities = viewModel.getCities(for: country)
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let country = viewModel.getCountries()[indexPath.section]
        let cities = viewModel.getCities(for: country)
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = cities[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.getCountries()[section].name
    }
    
}

// MARK: - UITableViewDataSource

extension SelectCityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let country = viewModel.getCountries()[indexPath.section]
        let cities = viewModel.getCities(for: country)
        let city = cities[indexPath.row]
        
        dismiss(animated: true) {
            self.viewModel.setUserSelectedCity(city)
        }
        
    }
    
}

// MARK: SnapKit

extension SelectCityViewController {
    
    func setConstraints() {
        
        view.addSubview(citiesTableView)
        citiesTableView.snp.makeConstraints { (maker) in
            maker.top.equalTo(view)
            maker.bottom.equalTo(view)
            maker.left.equalTo(view)
            maker.right.equalTo(view)
        }
        
    }
    
}
