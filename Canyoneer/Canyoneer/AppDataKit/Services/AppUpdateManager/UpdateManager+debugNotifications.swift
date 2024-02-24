//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import UserNotifications

/// Debug notifications so we can get details about background tasks working
extension UpdateManager {
    var userNotificationCenter: UNUserNotificationCenter { UNUserNotificationCenter.current() }
    func registerForNotifications() {
        #if !DEBUG
        return // ensure we never run this in production
        #endif
        let authOptions = UNAuthorizationOptions.alert
        userNotificationCenter.requestAuthorization(options: authOptions) { success, error in
            if let error {
                Global.logger.error(error)
            }
        }
    }
    
    func manualUpdateNotify() {
        #if !DEBUG
        return // ensure we never run this in production
        #endif
        let content = UNMutableNotificationContent()
        content.title = "Manual update started!"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "test_bg_manual_start", content: content, trigger: trigger)
        userNotificationCenter.add(request)
    }
    
    func didRegisterNotify(error: Error?) {
        #if !DEBUG
        return // ensure we never run this in production
        #endif
        let content = UNMutableNotificationContent()
        if let error {
            content.title = "BG update register failure!"
            content.body = error.localizedDescription
        } else {
            content.title = "BG update registered!"
            let duration = DateComponentsFormatter.duration(for: (nextScheduledUpdate?.timeIntervalSinceNow ?? 0))
            content.body = "Next scheduled sometime after \(duration)"
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "test_bg_register", content: content, trigger: trigger)
        userNotificationCenter.add(request)
    }
    
    func didStartNotify() {
        #if !DEBUG
        return // ensure we never run this in production
        #endif
        let content = UNMutableNotificationContent()
        content.title = "BG update started!"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "test_bg_start", content: content, trigger: trigger)
        userNotificationCenter.add(request)
    }
    
    func completedUpdateNotify(with error: Error?) {
        #if !DEBUG
        return // ensure we never run this in production
        #endif
        let content = UNMutableNotificationContent()
        if let error {
            let updateError = (error as? IndexUpdateError) ?? IndexUpdateError.unknown(error.localizedDescription)
            content.title = "BG update failed"
            content.body = updateError.debugDetails
        } else {
            content.title = "BG update succeeded"
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "test_bg_end", content: content, trigger: trigger)
        userNotificationCenter.add(request)
    }
}
