//
//  PasswordsViewControllerViewModel.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import Foundation

protocol PasswordsViewControllerViewModelViewDelegate: AnyObject {
    func update(with passwords: [PasswordTableViewCellViewModel])
}

class PasswordsViewControllerViewModel: ViewModel {
    var dependencies: AllDependencies
    var addVM: AddPasswordViewControllerViewModel {
        AddPasswordViewControllerViewModel(dependencies: dependencies)
    }
    weak var viewDelegate: PasswordsViewControllerViewModelViewDelegate?
    
    init(dependencies: AllDependencies) {
        self.dependencies = dependencies
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(getPasswords),
            name: .reloadPasswords,
            object: nil
        )
        getPasswords()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .reloadPasswords, object: nil)
    }
    
    @objc func getPasswords() {
        dependencies.session.getAllPasswords { [weak self] passwords in
            guard let passwords = passwords else { return }
            self?.viewDelegate?.update(
                with: passwords.map({ PasswordTableViewCellViewModel(password: $0) })
            )
        }
    }
    
    func addVM(for password: Password) -> AddPasswordViewControllerViewModel {
        return AddPasswordViewControllerViewModel(dependencies: dependencies, password: password)
    }
}
