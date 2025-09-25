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
            VStack{
                if let user = user {
                    Text(user.name)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    Form {
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
                    }
                } else {
                    Text("No user found")
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, configurations: config)
    let context = container.mainContext
    let previewUser = User(name: "Preview User", bio: "Loves iOS dev")
    context.insert(previewUser)

    return ProfileView()
        .modelContainer(container)
}
