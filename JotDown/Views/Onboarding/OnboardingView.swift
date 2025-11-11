//
//  OnboardingView.swift
//  JotDown
//
//  Created by Adam Ress on 10/28/25.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    
    @Environment(\.modelContext) private var context
    
    @State var selectedCategories: [Category] = []
    @State var suggestedCategories: [Category] = []
    
    @State var userInput: String = ""
    
    @State var currentPage: Int = 0
    @State var pageHeight: Int = 437
    
    @State var isGenerating: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ZStack {
                    UnevenRoundedRectangle(topLeadingRadius: 34, topTrailingRadius: 34)
                        .foregroundStyle(.white)
                        .ignoresSafeArea()
                        .frame(height: CGFloat(pageHeight))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: pageHeight)
                    
                    VStack {
                        if (currentPage == 1 || currentPage == 2) {
                            HStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(height: 6)
                                    .padding(.trailing, 5)
                                    .foregroundStyle(
                                        (currentPage == 1) ? Color.mediumText : Color.placeholderText
                                    )
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(height: 6)
                                    .padding(.leading, 5)
                                    .foregroundStyle(
                                        (currentPage == 2) ? Color.mediumText : Color.placeholderText
                                    )
                            }
                            .padding(.horizontal, 50)
                            .padding(.top, 70)
                        }
                        
                        Group {
                            switch currentPage {
                            case 0:
                                WelcomePage()
                                
                            case 1:
                                InfoPage(currentPage: $currentPage, pageHeight: $pageHeight)
                                
                            case 2:
                                CategoriesExamplePage(currentPage: $currentPage, pageHeight: $pageHeight)
                                
                            case 3:
                                PromptPage(userInput: $userInput) {
                                    await generateCategories()
                                }
                                
                            case 4:
                                if isGenerating {
                                    LoadingPage()
                                } else {
                                    CategorySelectionPage(
                                        selectedCategories: $selectedCategories,
                                        suggestedCategories: $suggestedCategories
                                    )
                                }
                                
                            default:
                                EmptyView()
                            }
                        }
                        .transition(.opacity)

                        
                        if (!isGenerating || currentPage > 4) {
                            HStack {
                                if (currentPage != 0) {
                                    BackButton(currentPage: $currentPage, pageHeight: $pageHeight)
                                    
                                    Spacer()
                                }
                                
                                ContinueButton(currentPage: $currentPage, pageHeight: $pageHeight,
                                   generateCategories: {
                                        await generateCategories()
                                    },
                                   onFinishOnboarding: {
                                        uploadSelectedCategories()
                                    }
                                )
                                .disabled((currentPage == 3 && userInput.isEmpty))
                                .opacity((currentPage == 3 && userInput.isEmpty) ? 0.5 : 1.0)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 50)
                        }
                        
                        
                    }
                    .frame(height: CGFloat(pageHeight))
                }
            }
            .ignoresSafeArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
          EllipticalGradient(
            stops: [
              Gradient.Stop(color: Color(red: 0.88, green: 0.97, blue: 1), location: 0.00),
              Gradient.Stop(color: .white.opacity(0), location: 1.00),
            ],
            center: UnitPoint(x: 0.2, y: 0.29)
          )
        )
        .background(
          EllipticalGradient(
            stops: [
              Gradient.Stop(color: Color(red: 1, green: 0.92, blue: 0.96).opacity(0.86), location: 0.00),
              Gradient.Stop(color: .white.opacity(0), location: 1.00),
            ],
            center: UnitPoint(x: 0.18, y: 0.7)
          )
        )
        .background(
          EllipticalGradient(
            stops: [
              Gradient.Stop(color: Color(red: 0.94, green: 0.94, blue: 0.99), location: 0.10),
              Gradient.Stop(color: Color(red: 0.96, green: 0.96, blue: 0.97), location: 1.00),
            ],
            center: UnitPoint(x: 0.82, y: 0.42)
          )
        )
        .ignoresSafeArea()
        .ignoresSafeArea(.keyboard)
    }
    
    @MainActor
    private func generateCategories() async {
        
        //Begin generating
        isGenerating = true
        
        let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedInput.isEmpty else {
            suggestedCategories = []
            return
        }

        do {
            let generator = CategoryGenerator()
            let newCategories = try await generator.generateCategories(using: trimmedInput)
            suggestedCategories = newCategories.filter { $0.name.lowercased() != "other" }
            isGenerating = false
        } catch {
            print("Failed to generate categories: \(error)")
            suggestedCategories = []
            isGenerating = false
        }
    }
    
    @MainActor
    private func uploadSelectedCategories() {
        // Create a new User object with the bio and selected categories
        let newUser = User(name: "", bio: userInput)
        
        // Insert the new user into the model context
        context.insert(newUser)
        
        let otherCategory = Category(name: "Other", categoryDescription: "For all other notes that don't match with given categories.")
        context.insert(otherCategory)
        
        for category in selectedCategories {
            context.insert(category)
        }
        
        //save the context
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }


}



#Preview {
    OnboardingView()
}
