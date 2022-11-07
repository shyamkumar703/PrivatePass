//
//  PasswordTableViewCell.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import UIKit

struct PasswordTableViewCellViewModel {
    var password: Password
    var hiddenPasswordString: String {
        String(repeating: "·", count: password.password.count)
    }
}

class PasswordTableViewCell: UITableViewCell {
    
    var viewModel: PasswordTableViewCellViewModel? {
        didSet {
            updateView()
        }
    }
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 4
        
        stack.addArrangedSubview(websiteLabel)
        stack.addArrangedSubview(usernameLabel)
        return stack
    }()
    
    var websiteLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .clear
        contentView.addSubview(stack)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        ])
    }
    
    func updateView() {
        guard let viewModel = viewModel else { return }
        websiteLabel.text = viewModel.password.website
        usernameLabel.text = viewModel.password.username
    }
}
