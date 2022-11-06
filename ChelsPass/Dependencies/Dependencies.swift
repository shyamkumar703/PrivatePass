//
//  Dependencies.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import Foundation

protocol AllDependencies: HasEncryption, HasSession {}

protocol HasEncryption {
    var encryption: Encryption { get }
}

protocol HasSession {
    var session: Session { get }
}

class Dependencies: AllDependencies {
    var encryption: Encryption = EncryptionManager()
    lazy var session: Session = SessionManager(dependencies: self)
}
