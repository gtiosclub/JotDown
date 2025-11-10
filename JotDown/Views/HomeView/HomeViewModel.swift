import SwiftUI
import SwiftData

@Observable
class HomeViewModel {
    var thoughtInput: String = ""
    var selectedIndex: Int? = 0 {
        didSet {
            if selectedIndex == 0 {
                isSelecting = false
            }
        }
    }
    var isSubmitting: Bool = false
    var showWritableThought: Bool = true
    var isSelecting: Bool = false
    var isEditing: Bool = false
    var selectedThoughts: Set<Thought> = []
    var thoughtBeingEdited: Thought? = nil

    private let context: ModelContext
    private let dismiss: DismissAction

    init(context: ModelContext, dismiss: DismissAction) {
        self.context = context
        self.dismiss = dismiss
    }

    private var categories: [Category] {
        (try? context.fetch(FetchDescriptor<Category>())) ?? []
    }

    @MainActor
    func addThought() async throws {
        defer {
            Task {
                await MainActor.run {
                    isSubmitting = false
                }
            }
        }

        guard !thoughtInput.isEmpty else { return }
        isSubmitting = true

        let thought = Thought(content: thoughtInput)

        try? await Categorizer()
            .categorizeThought(thought, categories: categories)

        context.insert(thought)
        dismiss()

        thoughtInput = ""
        selectedIndex = 1
        showWritableThought = false
    }

    @MainActor
    func saveEditedThought() async throws {
        guard let thoughtToEdit = thoughtBeingEdited else { return }

        thoughtToEdit.content = thoughtInput

        try? await Categorizer()
            .categorizeThought(thoughtToEdit, categories: categories)

        try? context.save()

        thoughtInput = ""
        thoughtBeingEdited = nil
        isSelecting = false
        selectedThoughts.removeAll()

        if let thoughts = try? context.fetch(FetchDescriptor<Thought>(sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])),
           let index = thoughts.firstIndex(of: thoughtToEdit) {
            selectedIndex = index + 1
        }
    }

    @MainActor
    func deleteSelectedThoughts() async throws {
        guard !selectedThoughts.isEmpty else { return }

        let allThoughts = try context.fetch(FetchDescriptor<Thought>(sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]))
        let previousIndex = selectedIndex ?? 0
        let newCount = allThoughts.count - selectedThoughts.count

        if newCount == 0 {
            selectedIndex = 0
        } else {
            selectedIndex = min(previousIndex, newCount)
        }

        for thought in selectedThoughts {
            context.delete(thought)
        }

        try context.save()

        await MainActor.run {
            selectedThoughts.removeAll()
        }
    }

    func cancelSelection() {
        isSelecting = false
        selectedThoughts.removeAll()
    }

    func cancelEditing() {
        isSelecting = false
        selectedThoughts.removeAll()
        isEditing = false
        selectedIndex = 0
        thoughtInput = ""
    }

    func startEditing(thought: Thought) {
        thoughtInput = thought.content
        thoughtBeingEdited = thought
        selectedIndex = 0
        isSelecting = false
        isEditing = true
    }

    func toggleSelection(for thought: Thought) {
        if selectedThoughts.contains(thought) {
            selectedThoughts.remove(thought)
        } else {
            selectedThoughts.insert(thought)
        }
    }
}
