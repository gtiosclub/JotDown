//
//  HomeView.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: \Thought.dateCreated, order: .reverse) var thoughts: [Thought]
    @Query private var categories: [Category]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State var thoughtInput: String = ""
    @State private var selectedIndex: Int? = 0
    @FocusState private var isFocused: Bool
    @State var isSubmitting = false
    @State private var isSelecting: Bool = false
    @State private var selectedThoughts: Set<Thought> = []
    @State private var thoughtBeingEdited: Thought? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            HeaderHomeView(thoughtInput: $thoughtInput, selectedIndex: $selectedIndex, isSubmitting: $isSubmitting, isFocused: _isFocused, addThought: addThought, saveEditedThought: saveEditedThought, isSelecting: $isSelecting,
                           selectedThoughts: $selectedThoughts, thoughtBeingEdited: $thoughtBeingEdited)
            ThoughtCardsList(thoughts: thoughts, text: $thoughtInput, selectedIndex: $selectedIndex, isFocused: _isFocused, isSelecting: $isSelecting,
                             selectedThoughts: $selectedThoughts, addThought: addThought)
            FooterHomeView(noteCount: thoughts.count, date: selectedIndex != nil && selectedIndex != 0 ? thoughts[selectedIndex! - 1].dateCreated : Date())
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            EllipticalGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.94, green: 0.87, blue: 0.94), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.78, green: 0.85, blue: 0.93), location: 1.00),
                ],
                center: UnitPoint(x: 0.67, y: 0.46)
            )
            .ignoresSafeArea()
        }
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            isFocused = false
        }
    }
    
    func addThought() async throws -> Void {
        isFocused = false
        await MainActor.run { isSubmitting = true }
        defer {
            Task { await MainActor.run { isSubmitting = false } }
        }

        let thought = Thought(content: thoughtInput)

        try? await Categorizer()
            .categorizeThought(thought, categories: categories)

        context.insert(thought)
        dismiss()
        
        thoughtInput = ""
    }
    
    func saveEditedThought() async throws {
        if let thoughtToEdit = thoughtBeingEdited {
            thoughtToEdit.content = thoughtInput
            
            try? await Categorizer()
                .categorizeThought(thoughtToEdit, categories: categories)
            
            try? context.save()
            
            // Reset UI state
            thoughtInput = ""
            thoughtBeingEdited = nil
            isSelecting = false
            selectedThoughts.removeAll()
        }
    }
}
