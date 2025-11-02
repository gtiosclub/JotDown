//
//  ThoughtCard.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/14/25.
//
import SwiftUI
import SwiftData

struct ThoughtCard: View {
    var thought: Thought
    @Environment(\.modelContext) private var context
    @Namespace private var namespace
    
    @State private var isEditing: Bool = false
    @State private var draftContent: String = ""
    @State private var isSaving: Bool = false
    @State private var saveError: String? = nil
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        ZStack(alignment: .top) {
           RoundedRectangle(cornerRadius: 30)
               .fill(Color.white.opacity(0.61))
               .frame(width: 251, height: 436)
//               .glassEffect()
               .shadow(color: Color.black.opacity(0.05), radius: 7.7, x: 0, y: 2)
           
           VStack(alignment: .leading) {
               Text(thought.content)
                   .frame(maxWidth: .infinity, alignment: .leading)
                   .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                   .font(.custom("SF Pro", size: 24))
                   .lineSpacing(12)
                   .fontWeight(.regular)
                   .truncationMode(.tail)

               Spacer()

               HStack {
                   Text(ThoughtCard.timeFormatter.string(from: thought.dateCreated))
                       .font(.system(size: 16, weight: .regular))
                       .italic()
                       .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                       .lineLimit(1)
                       .truncationMode(.tail)
                   Spacer()
                   
                   if (thought.category.isActive) {
                       NavigationLink(destination: CategoryDashboardView(category: thought.category, namespace: namespace)) {
                           HStack(spacing: 2) {
                               Text(thought.category.name)
                                   .font(.system(size: 16, weight: .regular))
                                   .italic()
                                   .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                                   .lineLimit(1)
                                   .truncationMode(.tail)
                               Text("→")
                                   .font(.system(size: 16, weight: .regular))
                                   .italic()
                                   .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                                   .padding(EdgeInsets(top: 0, leading: -2, bottom: 0, trailing: 0))
                           }
                       }
                       .buttonStyle(PlainButtonStyle())
                   } else {
                       Text(thought.category.name)
                           .font(.system(size: 16, weight: .regular))
                           .italic()
                           .foregroundColor(.gray.opacity(0.6))
                           .lineLimit(1)
                           .truncationMode(.tail)
                   }
                   
                   Button(action: {
                       draftContent = thought.content
                       isEditing = true
                   }) {
                       Image(systemName: "pencil")
                           .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                   }
                   .buttonStyle(PlainButtonStyle())
                   .padding(.leading, 8)
               }
           }
           .padding(EdgeInsets(top: 23, leading: 14, bottom: 23, trailing: 14))
           .frame(width: 251, height: 436)
       }
       .frame(width: 251, height: 472)
       .sheet(isPresented: $isEditing) {
          NavigationStack {
              VStack {
                  TextEditor(text: $draftContent)
                      .padding()
                      .frame(minHeight: 200)
                      .overlay(
                          RoundedRectangle(cornerRadius: 8)
                              .stroke(Color.gray.opacity(0.2))
                      )
                      .autocorrectionDisabled(false)

                  Spacer()
                  
                  if let saveError {
                      Text(saveError)
                          .foregroundColor(.red)
                          .font(.caption)
                  }
              }
              .padding()
              .navigationTitle("Edit Note")
              .toolbar {
                  ToolbarItem(placement: .cancellationAction) {
                      Button("Cancel") {
                          isEditing = false
                          saveError = nil
                      }
                  }
                  ToolbarItem(placement: .confirmationAction) {
                      if isSaving {
                          ProgressView()
                      } else {
                          Button("Save") {
                              Task {
                                  await saveEditedThought()
                              }
                          }
                          .disabled(draftContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                      }
                  }
              }
          }
      }
   }
   
   @MainActor
   private func saveEditedThought() async {
       saveError = nil
       isSaving = true
       defer { isSaving = false }
       
       let newContent = draftContent.trimmingCharacters(in: .whitespacesAndNewlines)
       guard !newContent.isEmpty else {
           saveError = "Note cannot be empty."
           return
       }
       
       thought.content = newContent

       let newEmbedding = RAGSystem().getEmbedding(for: newContent)
       thought.vectorEmbedding = newEmbedding
       
       let descriptor = FetchDescriptor<Category>()
       var categories: [Category] = []
       do {
           categories = try context.fetch(descriptor)
       } catch {
           
       }
       
       if !categories.isEmpty {
           do {
               try await Categorizer().categorizeThought(thought, categories: categories)
           } catch {
               saveError = "Recategorization failed: \(error.localizedDescription)"
           }
       } else {
           if thought.category.name.isEmpty {
               let other = Category(name: "Other", categoryDescription: "Other Category", isActive: true)
               context.insert(other)
               thought.category = other
           }
       }
       
       do {
           try context.save()
       } catch {
           saveError = "Failed to save note locally: \(error.localizedDescription)"
           return
       }

       if saveError == nil {
           isEditing = false
       }
   }
}

