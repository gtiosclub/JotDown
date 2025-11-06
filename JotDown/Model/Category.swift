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
    var categoryDescription: String
    var isActive: Bool
    static var dummyCategories = [
        Category(name: "Class", categoryDescription: "Related to school or educational classes", isActive: true),
        Category(name: "Work", categoryDescription: "Tasks and projects related to professional work", isActive: false),
        Category(name: "Music", categoryDescription: "Activities involving music listening or creation", isActive: true),
        Category(name: "Personal", categoryDescription: "Personal errands and self-care activities", isActive: true)
    ]
    
    init(name: String, categoryDescription: String, isActive: Bool = true) {
        self.name = name
        self.categoryDescription = categoryDescription
        self.isActive = isActive
    }
    
}
