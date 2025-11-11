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
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    @State private var viewModel: HomeViewModel?
    @Binding var selectedTab: Int
    @Binding var categoryToPresent: Category?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            if let viewModel {
                HeaderHomeView(isFocused: _isFocused)
                ThoughtCardsList(thoughts: thoughts, isFocused: _isFocused, selectedTab: $selectedTab, categoryToPresent: $categoryToPresent)
                FooterHomeView(noteCount: thoughts.count, date: viewModel.selectedIndex != nil && viewModel.selectedIndex != 0 ? thoughts[viewModel.selectedIndex! - 1].dateCreated : Date())
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .primaryBackground()
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            isFocused = false
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HomeViewModel(context: context, dismiss: dismiss)
            }
        }
        .environment(viewModel)
    }
}
