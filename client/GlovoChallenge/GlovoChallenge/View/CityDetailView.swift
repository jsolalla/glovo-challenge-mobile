//
//  CityDetailView.swift
//  GlovoChallenge
//
//  Created by Jesus Santa Olalla  (Vendor) on 7/9/18.
//  Copyright © 2018 Jesus Santa Olalla. All rights reserved.
//

import UIKit
import SnapKit

class CityDetailView: UIView {

    var shown = false
    
    lazy var lblCity: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()

    lazy var lblCurrency: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    lazy var lblTimeZone: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConstraints()
    }
    
    func setConstraints() {
        
        addSubview(lblCity)
        lblCity.snp.makeConstraints { (maker) in
            maker.left.top.equalTo(16)
            maker.height.equalTo(20)
        }
        
        addSubview(lblCurrency)
        lblCurrency.snp.makeConstraints { (maker) in
            maker.left.equalTo(lblCity.snp.right).offset(8)
            maker.height.equalTo(20)
            maker.top.equalTo(16)
        }
        
        addSubview(lblTimeZone)
        lblTimeZone.snp.makeConstraints { (maker) in
            maker.left.right.equalTo(16)
            maker.height.equalTo(20)
            maker.top.equalTo(lblCity.snp.bottom).offset(8)
        }
        
    }
    
}
