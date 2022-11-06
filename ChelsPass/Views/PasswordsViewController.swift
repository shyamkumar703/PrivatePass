//
//  PasswordsViewController.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import UIKit

class PasswordsViewController: ViewController<PasswordsViewControllerViewModel> {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    func setupView() {
        navigationItem.title = "Passwords"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupConstraints() {}
}
