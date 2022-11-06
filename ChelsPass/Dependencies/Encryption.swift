//
//  Encryption.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import Foundation

protocol Encryption {
    func encrypt(_ string: String) throws -> Data
    func decrypt(_ data: Data) throws -> String
}

class EncryptionManager: Encryption {
    private var aes: AES? = try? AES(keyString: "qawksidlsoakbbeisAskdielsiEskeo,")
    
    func encrypt(_ string: String) throws -> Data {
        guard let aes = aes else {
            throw Error.aesInitializationFailed
        }
        return try aes.encrypt(string)
    }
    
    func decrypt(_ data: Data) throws -> String {
        guard let aes = aes else {
            throw Error.aesInitializationFailed
        }
        return try aes.decrypt(data)
    }
}

extension EncryptionManager {
    enum Error: Swift.Error {
        case aesInitializationFailed
    }
}
