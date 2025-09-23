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
    
    init(name: String) {
        self.name = name
    }
}
