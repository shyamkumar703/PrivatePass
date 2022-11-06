//
//  Password.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import Foundation

class Password: Codable {
    var website: String
    var username: String
    var password: String
    
    init(website: String, username: String, password: String) {
        self.website = website
        self.username = username
        self.password = password
    }
}
