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
    
    private var context: ModelContext?
    
    func setup(context: ModelContext) {
        // TODO: Setup a WCSession
        // Hint: This will need to be called somewhere in the app lifecycle
        self.context = context
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
    }

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
            
        
        
        }

    

    // Required stubs
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
