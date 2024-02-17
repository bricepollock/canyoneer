//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import UserNotifications
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate { 
    func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
   ) -> Bool {
       
       #if DEBUG
       Global.logger.debug("Watching background updates with notifications!")
       UpdateManager.shared.userNotificationCenter.delegate = self
       UpdateManager.shared.registerForNotifications()
       #endif
       
       // Wasn't able to get background tasks working reliably enough to ship to production
       // https://github.com/bricepollock/canyoneer/issues/29
//       UpdateManager.shared.registerForBackgroundTask()

       return true
   }
    
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // Handle receiving of notification
    }
    
    // Needed if notifications should be presented while the app is in the foreground
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.list, .banner])
    }
}
