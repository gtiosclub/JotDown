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
    static var dummyCategories = [Category(name: "Class", isActive: true), Category(name: "Work", isActive: false), Category(name: "Music", isActive: true), Category(name: "Personal", isActive: true)]
    
    init(name: String, isActive: Bool = true) {
        self.name = name
        self.isActive = isActive
    }
    
}
