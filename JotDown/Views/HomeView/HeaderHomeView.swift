//
//  HeaderHomeView.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/14/25.
//

import SwiftUI
import SwiftData

struct HeaderHomeView: View {
    @Bindable var viewModel: HomeViewModel
    @FocusState var isFocused: Bool

    var body: some View {
        HStack {
            if viewModel.isEditing {
                Button {
                    viewModel.cancelEditing()
                    isFocused = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("cancel")
                    }
                }
                .font(Font.custom("SF Pro", size: 20))
                .foregroundColor(.secondaryText)
                .padding(0)

                Spacer()

                Button {
                    viewModel.selectedIndex = 0
                    isFocused = true
                    viewModel.isEditing = false
                    Task {
                        try await viewModel.saveEditedThought()
                    }
                } label: {
                    Text("done")
                        .font(Font.custom("SF Pro", size: 15)
                            .weight(.medium))
                        .foregroundColor(.white)
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .medium))
                        .frame(width: 15, height: 15)
                }
                .disabled(viewModel.selectedThoughts.count != 1)
                .opacity(viewModel.selectedThoughts.count != 1 ? 0.6: 1.0)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(LinearGradient.primaryButton)
                .cornerRadius(25)
            } else if viewModel.isSelecting {
                Button {
                    viewModel.cancelSelection()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("cancel")
                    }
                }
                .font(Font.custom("SF Pro", size: 20))
                .foregroundColor(.secondaryText)
                .padding(0)

                Spacer()

                Button {
                    if let thoughtToEdit = viewModel.selectedThoughts.first {
                        viewModel.startEditing(thought: thoughtToEdit)
                        isFocused = true
                    }
                } label: {
                    Text("edit")
                        .font(Font.custom("SF Pro", size: 15)
                            .weight(.medium))
                        .foregroundColor(.white)
                    Image(systemName: "pencil")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .medium))
                        .frame(width: 15, height: 15)
                }
                .disabled(viewModel.selectedThoughts.count != 1)
                .opacity(viewModel.selectedThoughts.count != 1 ? 0.6: 1.0)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(LinearGradient.primaryButton)
                .cornerRadius(25)

                Button {
                    Task {
                        try await viewModel.deleteSelectedThoughts()
                    }
                } label: {
                    Text("delete")
                        .font(Font.custom("SF Pro", size: 15)
                            .weight(.medium))
                        .foregroundColor(.white)
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .medium))
                        .frame(width: 15, height: 15)
                }
                .disabled(viewModel.selectedThoughts.isEmpty)
                .opacity(viewModel.selectedThoughts.isEmpty ? 0.6: 1.0)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(LinearGradient.primaryButton)
                .cornerRadius(25)
                
            } else {
                JotDownLogo()

                Spacer()

                Button {
                    viewModel.isSelecting = true
                    isFocused = false
                } label: {
                    Text("select")
                        .font(Font.custom("SF Pro", size: 15)
                            .weight(.medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(LinearGradient.primaryButton)
                .disabled(viewModel.selectedIndex == 0)
                .opacity(viewModel.selectedIndex == 0 ? 0.6 : 1.0)
                .cornerRadius(25)

                if viewModel.isSubmitting {
                    ProgressView()
                } else {
                    Button {
                        isFocused = false
                        if viewModel.selectedIndex != nil && viewModel.selectedIndex != 0 {
                            viewModel.showWritableThought = true
                            viewModel.selectedIndex = 0
                            isFocused = true
                        } else {
                            Task {
                                try await viewModel.addThought()
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.selectedIndex != 0 ? "plus" : "checkmark")
                            .fontWeight(.light)
                            .font(.system(size: 30))
                            .foregroundStyle(Color(red: 109/255, green: 134/255, blue: 166/255))
                            .padding(.vertical, 10)
                            .frame(width: 30, height: 30)
                    }
                    .disabled(viewModel.thoughtInput.trimmingCharacters(in: .whitespacesAndNewlines) == "" && viewModel.selectedIndex == 0)
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 0)
        .frame(height: 100)
        .onChange(of: viewModel.selectedIndex) {
            if viewModel.selectedIndex == 0 && !viewModel.isEditing {
                viewModel.isSelecting = false
                viewModel.selectedThoughts.removeAll()
            }
        }
    }
}
