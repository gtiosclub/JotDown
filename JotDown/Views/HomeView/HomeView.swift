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
    @State var text: String = ""
    @State private var selectedIndex: Int? = 0
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            HeaderHomeView(thoughtInput: $text, selectedIndex: $selectedIndex)
            ThoughtCardsList(thoughts: thoughts, text: $text, selectedIndex: $selectedIndex)
            FooterHomeView(noteCount: thoughts.count, date: selectedIndex != nil && selectedIndex != 0 ? thoughts[selectedIndex! - 1].dateCreated : Date())
            
            Spacer()
            
            //Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
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
    }
}
