//
//  WatchSessionManager.swift
//  JotDownWatch Watch App
//
//  Created by Joseph Masson on 9/30/25.
//

import WatchConnectivity
import Combine

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSessionManager()

    override init() {
        super.init()
        activateSession()
    }

    private func activateSession() {
        // TODO: Activate a WCSession
    }

    func requestThoughts() {
        // TODO: Request thoughts from iPhone if reachable. Store them to be called in the Watch Views
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            requestThoughts()
        }
    }

    // Required stub
    func session(_ session:WCSession, didReceiveMessage message: [String: Any]) {}
}
