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
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Bio") {
                    // FIXME: Implement
                    TextField("Describe yourself...", text: .constant(""))
                }
                
                Section("Categories") {
                    // FIXME: Implement
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
