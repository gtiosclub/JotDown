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
    
    @Query private var users: [User]
    @Query private var categories: [Category]
    private var user: User? { users.first }

    
    var body: some View {
        NavigationStack {
            Form {
                if let user = user {
                    Section("Name") {
                        TextField("Enter your name", text: Binding(
                            get: { user.name },
                            set: { user.name = $0 }
                        ))
                    }
                    Section("Bio") {
                        // FIXME: Implement
                        TextField("Describe yourself...", text: Binding(
                            get: { user.bio },
                            set: { user.bio = $0 }
                        ))
                    }
                    Section("Categories") {
                        // FIXME: Implement
                        ForEach(categories, id: \.name) { category in
                            Text(category.name)
                        }
                    }
                } else {
                    Text("No User Found.")
                        .foregroundColor(.secondary)
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
