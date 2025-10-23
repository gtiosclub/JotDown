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
    
    @Published var thoughts: [[String: Any]] = []
    
    override init() {
        super.init()
        activateSession()
    }
    
    private func activateSession() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    func requestThoughts() {
        guard WCSession.default.isReachable else {
            print("ERROR: Unable to reach phone")
            return
        }
        
        WCSession.default.sendMessage(["request": "thoughts"], replyHandler: { reply in
            if let rawThoughts = reply["items"] as? [[String: Any]] {
                DispatchQueue.main.async {
                    self.thoughts = rawThoughts
                }
            }
        }, errorHandler: { error in
            print("Error retrieving thoughts: \(error)")
        })
    }
    
    func sendThought(_ text: String) {
        guard WCSession.default.isReachable else {
            return
        }
        
        let message: [String: Any] = ["thought": text]
        
        WCSession.default.sendMessage(message, replyHandler: { reply in
            if let ok = reply["ok"] as? Bool, ok {
                DispatchQueue.main.async {
                    self.requestThoughts()
                }
            }
        }, errorHandler: { error in
            print("Error sending thought:", error.localizedDescription)
        })
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            requestThoughts()
        }
    }
    
    // Required stub
    func session(_ session:WCSession, didReceiveMessage message: [String: Any]) {}
}
