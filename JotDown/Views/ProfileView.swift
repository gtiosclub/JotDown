//
//  ProfileView.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Query var users: [User]
    private var user: User? { users.first }
//    @Query var categories: [Category]
    @State private var bio: String = ""
    @State private var showArchivedCategories: Bool = false
    private var activeCategories: [Category] {
        Category.dummyCategories.filter{$0.isActive}
    }
    private var inactiveCategories: [Category] {
        Category.dummyCategories.filter{!$0.isActive}
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Bio") {
                    // FIXME: Implement
                    TextField("Desribe yourself...", text: $bio)
                }
                
                Section("Active Categories") {
                    ForEach(activeCategories) { category in
                        Text(category.name)
                            .swipeActions(allowsFullSwipe: true) {
                                Button(role: .destructive, action: {
                                    withAnimation {
                                        category.isActive.toggle()
                                    }
                                }) {
                                   Text("Archive")
                                }
                            }
                    }
                    NavigationLink(destination: ArchivedCategoriesView(cateogries: inactiveCategories)) {
                        Text("\(inactiveCategories.count) inactive \(String(inactiveCategories.count).last == "1" ? "category" : "categories")")
                    }
                    .disabled(inactiveCategories.count == 0)
                }
                
                
                
            }
            
            .navigationTitle("Profile")
            .toolbar {
                Button(role: .close) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
