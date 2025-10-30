//
//  WatchSessionManager.swift
//  JotDown
//
//  Created by Joseph Masson on 9/30/25.
//

import WatchConnectivity
import SwiftData
import SwiftUI

class WatchSessionManager: NSObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    let fm = FoundationModelSearchService()
    
    private var context: ModelContext?
    
    func setup(context: ModelContext) {
        // TODO: Setup a WCSession
        // Hint: This will need to be called somewhere in the app lifecycle
        self.context = context
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = WatchSessionManager.shared
            session.activate()
        }
        
    }
    
    private lazy var iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        if let text = message["thought"] as? String, !text.isEmpty {
            // TODO: Save text entry from Apple Watch to SwiftData
            guard let context else {
                replyHandler(["ok": false, "error": "No SwiftData context"])
                return
            }
            let thought = Thought(content:text)
            //save to swiftData
            context.insert(thought)
            
            do {
                try context.save()
                replyHandler(["ok": true])
            } catch {
                replyHandler(["ok": false, "error": "Save failed: \(error.localizedDescription)"])
            }
            return
        }
        
        if message["request"] as? String == "thoughts" {
            // TODO: Fetch thoughts from SwiftData and send them to Apple Watch
            //sending the Thought as JSON format
            //fetch from swiftData and send to the watchUI
            
            let limit = (message["limit"] as? Int) ?? 50
            let sinceISO = message["since"] as? String
            let sinceDate = sinceISO.flatMap { iso.date(from: $0) }
            
            Task { @MainActor in
                guard let context = self.context else {
                    replyHandler(["ok": false, "error": "No SwiftData context"])
                    return
                }
                
                // Build predicate if needed
                var predicate: Predicate<Thought>? = nil
                if let sinceDate {
                    predicate = #Predicate<Thought> { $0.dateCreated >= sinceDate }
                }
                
                var descriptor = FetchDescriptor<Thought>(
                    predicate: predicate,
                    sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]
                )
                descriptor.fetchLimit = limit
                
                do {
                    let thoughts = try context.fetch(descriptor)
                    
                    //JSON file for Thought, but not sure how to handle the category(set as dummy now)
                    let items: [[String: Any]] = thoughts.map {
                        [
                            "content": $0.content,
                            "dateCreated": iso.string(from: $0.dateCreated),
                            "category": $0.category.name,
                            "categoryActive": $0.category.isActive
                        ]
                    }
                    
                    replyHandler(["ok": true, "items": items])
                } catch {
                    replyHandler(["ok": false, "error": "Fetch failed: \(error.localizedDescription)"])
                }
            }
            return
        }
        
        //Do the search request
        if message["request"] as? String == "searchresults" {
            let query = (message["query"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let limit = (message["limit"] as? Int) ?? 50
            let sinceISO = message["since"] as? String
            let sinceDate = sinceISO.flatMap { iso.date(from: $0) }

            guard !query.isEmpty else {
                replyHandler(["ok": false, "error": "Empty query"])
                return
            }
            
            Task { @MainActor in
                    guard let context = self.context else {
                        replyHandler(["ok": false, "error": "No SwiftData context"])
                        return
                    }

                    var predicate: Predicate<Thought>? = nil
                    if let sinceDate {
                        predicate = #Predicate<Thought> { $0.dateCreated >= sinceDate }
                    }

                    var descriptor = FetchDescriptor<Thought>(
                        predicate: predicate,
                        sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]
                    )
                    // should fetch more than the limit for filter further situation
                    descriptor.fetchLimit = max(limit * 3, 60)

                    do {
                        let allRecentThoughts = try context.fetch(descriptor)

                        //get the revelant list of thoughts
                        let relevant = await FoundationModelSearchService.getRelevantThoughts(query: query, in: allRecentThoughts)
                        
                        // handle the paylod size
                        let trimmed = Array(relevant.prefix(limit))
                        let items: [[String: Any]] = trimmed.map { t in // the t is the same as $0 (for Jeet)
                            // You can also truncate very long content to e.g. 500 chars
                            let content = t.content.count > 500 ? String(t.content.prefix(500)) + "…" : t.content
                            return [
                                "content": content,
                                "dateCreated": iso.string(from: t.dateCreated),
                                "category": t.category.name,
                                "categoryActive": t.category.isActive
                            ]
                        }

                        replyHandler([
                            "ok": true,
                            "items": items
                            
                        ])
                    } catch {
                        replyHandler(["ok": false, "error": "Fetch failed: \(error.localizedDescription)"])
                    }
                }
                return
        }
        
        replyHandler(["ok": false, "error": "Unknown message"])
    }
    
    // Required stubs
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
