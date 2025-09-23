//
//  User.swift
//  JotDown
//
//  Created by Степан Кравцов on 9/23/25.
//

import SwiftData

@Model
class User {
    var name: String
    var bio: String
    
    init(name: String, bio: String = "") {
        self.name = name
        self.bio = bio
    }
}

