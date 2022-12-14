//
//  AddPasswordViewControllerViewModel.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import Foundation

protocol AddPasswordViewControllerViewModelViewDelegate: AnyObject {
    func startLoading()
    func stopLoadingAndDismiss()
    func pushNext()
    func popBack()
}

class AddPasswordViewControllerViewModel: ViewModel {
    var dependencies: AllDependencies
    var screen: Screen
    weak var viewDelegate: AddPasswordViewControllerViewModelViewDelegate?
    
    // Data
    var website: String?
    var username:  String?
    var password: String?
    var existingId: String?
    
    // Computed properties
    var title: String {
        switch screen {
        case .website: return "The website is"
        case .username: return "My username is"
        case .password: return "My password is"
        }
    }
    
    var primaryButtonText: String {
        switch screen {
        case .website, .username: return "Next"
        case .password: return "Save"
        }
    }
    
    var secondaryButtonText: String? {
        switch screen {
        case .username, .password: return "Back"
        case .website: return nil
        }
    }
    
    var textFieldStarterText: String? {
        switch screen {
        case .website: return website
        case .username: return username
        case .password: return password
        }
    }
    
    init(dependencies: AllDependencies, screen: Screen = .website) {
        self.dependencies = dependencies
        self.screen = screen
    }
    
    init(dependencies: AllDependencies, password: Password, screen: Screen = .website) {
        self.dependencies = dependencies
        self.website = password.website
        self.username = password.username
        self.password = password.password
        self.screen = screen
        self.existingId = password.id
    }
    
    func nextTapped(with text: String) {
        switch screen {
        case .website:
            self.website = text
            screen = .username
            viewDelegate?.pushNext()
        case .username:
            self.username = text
            screen = .password
            viewDelegate?.pushNext()
        case .password:
            self.password = text
            save()
        }
    }
    
    func backTapped() {
        switch screen {
        case .website:
            break
        case .username:
            self.screen = .website
            viewDelegate?.popBack()
        case .password:
            self.screen = .username
            viewDelegate?.popBack()
        }
    }
    
    private func save() {
        guard let website = website,
              let username = username,
              let password = password else { return }
        let passwordToSave = Password(
            id: existingId ?? UUID().uuidString,
            website: website,
            username: username,
            password: password
        )
        if existingId != nil {
            dependencies.session.updatePassword(passwordToSave) { [weak self] _ in
                NotificationCenter.default.post(name: .reloadPasswords, object: nil)
                self?.viewDelegate?.stopLoadingAndDismiss()
            }
        } else {
            dependencies.session.addPassword(passwordToSave) { [weak self] _ in
                NotificationCenter.default.post(name: .reloadPasswords, object: nil)
                self?.viewDelegate?.stopLoadingAndDismiss()
            }
        }
    }
}

extension AddPasswordViewControllerViewModel {
    enum Screen {
        case website
        case username
        case password
    }
}
