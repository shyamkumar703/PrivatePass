//
//  SecondaryButton.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import UIKit

class SecondaryButton: UIButton {
    
    private var attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 16, weight: .regular),
        .foregroundColor: UIColor.blue
    ]
    
    var title: String? {
        didSet {
            guard let title = title else { return }
            setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setTitleColor(.blue, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
