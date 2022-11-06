//
//  Session.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import Foundation
import FirebaseFirestore

protocol Session {
    func getAllPasswords(completion: @escaping ([Password]?) -> Void)
    func addPassword(_ password: Password, completion: @escaping (Bool) -> Void)
}

class SessionManager: Session {
    var dependencies: AllDependencies
    
    init(dependencies: AllDependencies) {
        self.dependencies = dependencies
    }
    
    func getAllPasswords(completion: @escaping ([Password]?) -> Void) {
        Firestore.get(collectionPath: "chelsea", type: EncryptedPassword.self) { result in
            switch result {
            case .success(let passwords):
                completion(passwords.compactMap({ self.decrypt($0) }))
            case .failure:
                completion(nil)
            }
        }
    }
    
    func addPassword(_ password: Password, completion: @escaping (Bool) -> Void) {
        guard let encryptedPassword = encrypt(password) else {
            completion(false)
            return
        }
        Firestore.set(
            encryptedPassword,
            documentPath: "chelsea/\(UUID().uuidString)",
            completion: { result in
                switch result {
                case .success:
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        )
    }
    
    // MARK: - Utils
    private func decrypt(_ encryptedPassword: EncryptedPassword) -> Password? {
        guard let website = try? dependencies.encryption.decrypt(encryptedPassword.website),
              let username = try? dependencies.encryption.decrypt(encryptedPassword.username),
              let password = try? dependencies.encryption.decrypt(encryptedPassword.password) else {
                  return nil
        }
        return Password(website: website, username: username, password: password)
    }
    
    private func encrypt(_ password: Password) -> EncryptedPassword? {
        guard let encryptedWebsite = try? dependencies.encryption.encrypt(password.website),
              let encryptedUsername = try? dependencies.encryption.encrypt(password.username),
              let encryptedPassword = try? dependencies.encryption.encrypt(password.password) else {
            return nil
        }
        return EncryptedPassword(website: encryptedWebsite, username: encryptedUsername, password: encryptedPassword)
    }
}
