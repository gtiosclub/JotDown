//
//  Category.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import SwiftData

@Model
class Category {
    var name: String
    var isActive: Bool
    
    init(name: String, isActive: Bool = true) {
        self.name = name
        self.isActive = isActive
    }
}
