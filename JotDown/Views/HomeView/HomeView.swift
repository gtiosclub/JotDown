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
    
    var body: some View {
        VStack {
            HeaderHomeView()
            ThoughtCardsList(thoughts: thoughts)
            FooterHomeView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.opacity(0.3))
    }
}
