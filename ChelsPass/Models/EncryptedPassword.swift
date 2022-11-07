//
//  Password.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import Foundation

class EncryptedPassword: Codable {
    var id: String
    var website: Data
    var username: Data
    var password: Data
    init(id: String, website: Data, username: Data, password: Data) {
        self.id = id
        self.website = website
        self.username = username
        self.password = password
    }
}
