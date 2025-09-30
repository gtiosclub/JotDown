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
    
    func setup(context: ModelContext) {
        // TODO: Setup a WCSession
        // Hint: This will need to be called somewhere in the app lifecycle
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let text = message["thought"] as? String, !text.isEmpty {
            // TODO: Save text entry from Apple Watch to SwiftData
        }

        if message["request"] as? String == "thoughts" {
            // TODO: Fetch thoughts from SwiftData and send them to Apple Watch
        }
    }

    // Required stubs
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
