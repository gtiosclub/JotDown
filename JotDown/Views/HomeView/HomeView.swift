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
    @FocusState private var isFocused: Bool
    @State private var viewModel: HomeViewModel?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            if let viewModel {
                HeaderHomeView(viewModel: viewModel, isFocused: _isFocused)
                ThoughtCardsList(thoughts: thoughts, viewModel: viewModel, isFocused: _isFocused)
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
                viewModel = HomeViewModel(context: context, categories: categories, dismiss: dismiss)
            }
        }
    }
}
