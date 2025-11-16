//
//  HomeViewModel+Debug.swift
//  JotDown
//
//  Debug extension for populating sample data
//

#if DEBUG
import SwiftUI
import SwiftData

extension HomeViewModel {
    // Debug function to populate sample data
    @MainActor
    func populateSampleData() async throws {
        // Clear all existing data
        let existingThoughts = try context.fetch(FetchDescriptor<Thought>())
        for thought in existingThoughts {
            context.delete(thought)
        }

        let existingCategories = try context.fetch(FetchDescriptor<Category>())
        for category in existingCategories {
            context.delete(category)
        }

        let existingUsers = try context.fetch(FetchDescriptor<User>())
        for user in existingUsers {
            context.delete(user)
        }

        try context.save()

        // Create user with specified bio
        let user = User(
            name: "Ray",
            bio: "I am a student at Georgia Tech studying computer science interested in photography, film making and app development. I also want to keep track of my to do list and tasks so I don't forget things."
        )
        context.insert(user)

        // Create categories
        let photographyCategory = Category(
            name: "Photography",
            categoryDescription: "Photos, camera equipment, and visual composition",
            isActive: true
        )
        let filmMakingCategory = Category(
            name: "Film Making",
            categoryDescription: "Video production, editing, and storytelling",
            isActive: true
        )
        let appDevCategory = Category(
            name: "App Development",
            categoryDescription: "iOS development, coding projects, and tech ideas",
            isActive: true
        )
        let tasksCategory = Category(
            name: "Tasks & To-Do",
            categoryDescription: "Daily tasks, reminders, and things to remember",
            isActive: true
        )
        let schoolCategory = Category(
            name: "School",
            categoryDescription: "Classes, assignments, and academic activities",
            isActive: true
        )
        let otherCategory = Category(
            name: "Other",
            categoryDescription: "Thoughts which don't fit into the other categories",
            isActive: true
        )

        context.insert(photographyCategory)
        context.insert(filmMakingCategory)
        context.insert(appDevCategory)
        context.insert(tasksCategory)
        context.insert(schoolCategory)
        context.insert(otherCategory)

        // Create sample thoughts with appropriate emotions
        let sampleThoughts: [(String, Category, Emotion)] = [
            // Photography thoughts
            ("Captured some amazing golden hour shots at Piedmont Park today. The lighting was perfect!", photographyCategory, .happiness),
            ("Need to buy a new lens for my camera before the trip", photographyCategory, .calm),
            ("My portrait photography is improving. Really happy with the depth of field I achieved", photographyCategory, .happiness),
            ("Camera battery died during the shoot. So frustrating!", photographyCategory, .anger),
            ("Experimenting with long exposure night photography", photographyCategory, .calm),
            ("Got featured on the campus photography club Instagram!", photographyCategory, .happiness),
            ("Need to clean my camera sensor, seeing dust spots in all my photos", photographyCategory, .calm),
            ("Worried about affording a new camera body. Current one is acting up", photographyCategory, .fear),
            ("Street photography session downtown was amazing", photographyCategory, .happiness),
            ("Learning about color grading and photo editing in Lightroom", photographyCategory, .calm),
            ("Someone stole composition ideas from my photos. Really upset about it", photographyCategory, .anger),
            ("Sunrise shoot at Stone Mountain was worth waking up at 4am", photographyCategory, .happiness),
            ("Need to organize my photo library, it's a complete mess", photographyCategory, .calm),
            ("Portfolio review went poorly. Professor said my work lacks vision", photographyCategory, .sadness),
            ("Trying out film photography for the first time", photographyCategory, .calm),

            // Film Making thoughts
            ("Started editing the short film I shot last weekend. The footage looks promising", filmMakingCategory, .happiness),
            ("Brainstorming ideas for a documentary about campus life", filmMakingCategory, .calm),
            ("Audio quality is terrible on these clips. Need to invest in better microphones", filmMakingCategory, .sadness),
            ("Film club meeting Wednesday at 6pm", filmMakingCategory, .calm),
            ("Successfully color graded the entire film! Looks cinematic now", filmMakingCategory, .happiness),
            ("Stressed about finishing the film before the festival deadline", filmMakingCategory, .fear),
            ("Watched some Nolan films for inspiration. The cinematography is incredible", filmMakingCategory, .happiness),
            ("Need to schedule interviews for the documentary project", filmMakingCategory, .calm),
            ("Main actor dropped out of the project last minute. Panicking!", filmMakingCategory, .fear),
            ("Learning DaVinci Resolve for advanced color correction", filmMakingCategory, .calm),
            ("Film festival rejected my submission. Really disappointed", filmMakingCategory, .sadness),
            ("Got accepted to screen at the student film showcase!", filmMakingCategory, .happiness),
            ("Equipment rental costs are adding up quickly", filmMakingCategory, .fear),
            ("Storyboarding the next scene. This is the fun part", filmMakingCategory, .happiness),
            ("Feeling overwhelmed with all the post-production work", filmMakingCategory, .sadness),
            ("Found the perfect location for filming the final scene", filmMakingCategory, .happiness),
            ("Crew member flaked on shoot day. So angry right now", filmMakingCategory, .anger),
            ("Experimenting with different aspect ratios for the film", filmMakingCategory, .calm),

            // App Development thoughts
            ("Working on implementing SwiftUI animations in my app. The gesture recognizers are tricky", appDevCategory, .calm),
            ("Finally fixed that bug that was crashing the app! Took hours but worth it", appDevCategory, .strong),
            ("Excited about the new SwiftUI features in iOS 18", appDevCategory, .happiness),
            ("App Store rejection. Need to fix privacy policy issues", appDevCategory, .sadness),
            ("Learned about Combine framework today. Reactive programming is powerful", appDevCategory, .calm),
            ("Deployed the app to TestFlight! Beta testers are loving it", appDevCategory, .happiness),
            ("Struggling with memory leaks. The app keeps crashing after extended use", appDevCategory, .fear),
            ("Refactored the entire codebase. So much cleaner now", appDevCategory, .strong),
            ("Need to implement push notifications before the next release", appDevCategory, .calm),
            ("Got my first 5-star review on the App Store!", appDevCategory, .happiness),
            ("Database migration failed. Lost all test data", appDevCategory, .anger),
            ("Exploring ARKit for a new augmented reality feature", appDevCategory, .calm),
            ("Code review was brutal. Senior dev tore apart my implementation", appDevCategory, .sadness),
            ("Successfully integrated CloudKit for data syncing", appDevCategory, .happiness),
            ("API keeps timing out. Backend team needs to fix their servers", appDevCategory, .anger),
            ("Learning about MVVM architecture patterns", appDevCategory, .calm),
            ("App reached 1000 downloads! Incredible milestone", appDevCategory, .happiness),
            ("Worried about App Store algorithm changes affecting visibility", appDevCategory, .fear),
            ("Implementing accessibility features. Making apps inclusive is important", appDevCategory, .calm),
            ("Pulled an all-nighter to meet the hackathon deadline", appDevCategory, .strong),
            ("UI design is not my strength. Interface looks amateur", appDevCategory, .sadness),
            ("Found a great Swift package that solves my problem perfectly", appDevCategory, .happiness),
            ("Xcode crashed and I lost an hour of work. Didn't commit changes", appDevCategory, .anger),
            ("Watching WWDC sessions for best practices", appDevCategory, .calm),

            // Tasks & To-Do thoughts
            ("Remember to submit CS assignment by Friday", tasksCategory, .calm),
            ("Buy groceries and meal prep for the week", tasksCategory, .calm),
            ("Don't forget to call mom this weekend", tasksCategory, .calm),
            ("Need to renew parking pass before it expires", tasksCategory, .calm),
            ("Return library books by Tuesday", tasksCategory, .calm),
            ("Schedule dentist appointment", tasksCategory, .calm),
            ("Pay rent by the end of the month", tasksCategory, .calm),
            ("Laundry is piling up. Need to do it this weekend", tasksCategory, .calm),
            ("RSVP to Sarah's birthday party", tasksCategory, .calm),
            ("Update resume before career fair", tasksCategory, .calm),
            ("Get flu shot at student health center", tasksCategory, .calm),
            ("Oil change needed for the car", tasksCategory, .calm),
            ("Pick up package from mail room", tasksCategory, .calm),
            ("Renew gym membership", tasksCategory, .calm),
            ("Submit reimbursement form for conference travel", tasksCategory, .calm),
            ("Buy birthday gift for roommate", tasksCategory, .calm),
            ("Schedule meeting with academic advisor", tasksCategory, .calm),
            ("Cancel subscription that I'm not using", tasksCategory, .calm),
            ("Back up laptop data to external drive", tasksCategory, .calm),
            ("Water the plants before they die", tasksCategory, .calm),

            // School thoughts
            ("Midterm exam for Data Structures tomorrow morning. Need to review binary trees", schoolCategory, .fear),
            ("Group project presentation went really well! Professor loved our approach", schoolCategory, .happiness),
            ("Feeling overwhelmed with all the assignments due this week", schoolCategory, .sadness),
            ("Need to attend office hours for Linear Algebra", schoolCategory, .calm),
            ("Aced the algorithms quiz! All that studying paid off", schoolCategory, .happiness),
            ("Professor still hasn't graded our papers from three weeks ago", schoolCategory, .anger),
            ("Starting research project with Dr. Smith on machine learning", schoolCategory, .happiness),
            ("Failed the operating systems exam. Don't know how I'll recover my grade", schoolCategory, .sadness),
            ("Team member isn't pulling their weight on group project", schoolCategory, .anger),
            ("Lecture on distributed systems was fascinating today", schoolCategory, .calm),
            ("Registration for next semester opens tomorrow. Need to plan my schedule", schoolCategory, .calm),
            ("Terrified about the upcoming compiler design final", schoolCategory, .fear),
            ("Won the hackathon with my team! $1000 prize", schoolCategory, .happiness),
            ("TA was super helpful during lab session", schoolCategory, .happiness),
            ("Can't understand anything in theoretical CS class", schoolCategory, .sadness),
            ("Need to form a study group for discrete math", schoolCategory, .calm),
            ("Got invited to join honor society!", schoolCategory, .happiness),
            ("Stressing about maintaining my GPA for scholarship", schoolCategory, .fear),
            ("Class got cancelled. Unexpected free time!", schoolCategory, .happiness),
            ("Networking event with alumni was really valuable", schoolCategory, .calm),
            ("Professor caught someone cheating on the exam. Intense situation", schoolCategory, .fear),
            ("Successfully defended my research proposal", schoolCategory, .strong),
            ("Sleep-deprived from studying. This is unsustainable", schoolCategory, .sadness),
            ("Considering applying for internship at Google", schoolCategory, .calm),
            ("Got accepted into the CS capstone project I wanted!", schoolCategory, .happiness),
            ("Imposter syndrome hitting hard in advanced algorithms class", schoolCategory, .fear),
            ("Helping classmates understand recursion. Teaching helps me learn too", schoolCategory, .happiness),
            ("Campus internet is down again. Can't submit assignment", schoolCategory, .anger),
            ("Discovered a passion for computer graphics after taking the course", schoolCategory, .happiness),
            ("Need to drop one class. Taking too many credits this semester", schoolCategory, .sadness)
        ]

        for (content, category, emotion) in sampleThoughts {
            let thought = Thought(content: content)
            thought.category = category
            thought.emotion = emotion
            context.insert(thought)
        }

        try context.save()

        // Reset view model state
        thoughtInput = ""
        selectedIndex = 1
        showWritableThought = false
        isSelecting = false
        isEditing = false
        selectedThoughts.removeAll()
    }
}
#endif
