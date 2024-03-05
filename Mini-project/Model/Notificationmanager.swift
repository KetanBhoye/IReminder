//
//  Notificationmanager.swift
//  Mini-project
//
//  Created by mini project on 21/02/24.
//

import Foundation
import UserNotifications


class NotificationManager{
    static let instance = NotificationManager()
    
    func requestAuth (){
        let options : UNAuthorizationOptions = [.alert,.badge,.sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if (error != nil) {
                print (error)
            }
            else {
                print(success)
            }
        }
    }
    
    func scheduleNotification(title: String, body: String, date: Date,id : UUID) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        // Define custom actions
        let snooze = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let open = UNNotificationAction(identifier: "Open App", title: "Open App", options: [])

        // Create a category with the custom actions
        let category = UNNotificationCategory(identifier: "CustomCategory", actions: [snooze, open], intentIdentifiers: [],hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)

        // Register the category with the notification center
        UNUserNotificationCenter.current().setNotificationCategories([category])

        // Set the category identifier in the notification content
        content.categoryIdentifier = "CustomCategory"

        // Create notification trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        // Create notification request
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)

        // Schedule the notification
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if let err = error {
                print("Error scheduling notification: \(err)")
            } else {
                print("Notification scheduled successfully")
            }
        }
        notificationCenter.setNotificationCategories([category])
    }
}


//for in app interaction


class NotificationDelegate : NSObject, ObservableObject, UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge,.banner,.sound])
    }
}
