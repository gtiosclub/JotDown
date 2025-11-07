//
//  HeaderHomeView.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/14/25.
//

import SwiftUI
import SwiftData

struct HeaderHomeView: View {
    @Binding var thoughtInput: String
    @Binding var selectedIndex: Int?
    @Binding var isSubmitting: Bool
    @FocusState var isFocused: Bool
    let addThought: () async throws -> Void
    let saveEditedThought: () async throws -> Void
    @Binding var isSelecting: Bool
    @Binding var selectedThoughts: Set<Thought>
    @Binding var thoughtBeingEdited: Thought?
    
    var body: some View {
        HStack {
            if isSelecting {
                // MARK: - Selection Mode UI
                Button {
                    isSelecting = false
                    selectedThoughts.removeAll()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("cancel")
                    }
                }
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.blue)
                
                Spacer()
                
                Button("edit") {
                    if let thoughtToEdit = selectedThoughts.first {
                        thoughtInput = thoughtToEdit.content
                        thoughtBeingEdited = thoughtToEdit
                        selectedIndex = 0
                        isSelecting = false
                        isFocused = true
                    }
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.gray.opacity(selectedThoughts.count == 1 ? 1 : 0.4))
                .disabled(selectedThoughts.count != 1)
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
                
                Button("delete") {
                    // TODO
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(selectedThoughts.isEmpty ? .gray.opacity(0.4) : .blue)
                .disabled(selectedThoughts.isEmpty)
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
                
            } else {
                // MARK: - Normal Mode UI
                JotDownLogo()
                
                Spacer()
                
                Button("select") {
                    isSelecting = true
                    isFocused = false
                }
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
                
                Button {
                    isFocused = false

                    if thoughtBeingEdited != nil {
                        Task {
                            try await saveEditedThought()
                        }
                    } else {
                        Task {
                            try await addThought()
                        }
                    }

                } label: {
                    Image(systemName: selectedIndex != 0 ? "plus" : "checkmark")
                        .font(.system(size: 30))
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 0)
        .frame(height: 100)
    }
}
