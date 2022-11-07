//
//  PasswordsViewControllerViewModel.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import Foundation
import LocalAuthentication

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
        authenticate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .reloadPasswords, object: nil)
    }
    
    private func authenticate() {
        let context = LAContext()
        let biometry = context.biometryType
        var reason = "Log in with Face ID"
        switch biometry {
        case .touchID:
            reason = "Log in with Touch ID"
        case .faceID:
            reason = "Log in with Face ID"
        default:
            break
        }
        var error: NSError?
        var permissions = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        if permissions {
            // auth
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, error in
                if success {
                    self?.getPasswords()
                }
            }
        } else {
            // error
            print(error)
        }
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
