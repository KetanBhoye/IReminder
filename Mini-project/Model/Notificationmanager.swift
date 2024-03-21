import Foundation

import UserNotifications



class NotificationManager {

    static let instance = NotificationManager()

    

    func requestAuth() {

        let options: UNAuthorizationOptions = [.alert, .badge, .sound]

        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in

            if let error = error {

                print(error.localizedDescription)

            } else {

                print("Authorization granted: \(success)")

            }

        }

    }

    

    func scheduleNotification(title: String, body: String, date: Date, id: UUID) {

        let content = UNMutableNotificationContent()

        content.title = title

        content.body = body

        content.sound = UNNotificationSound.default

        

        let snooze = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])

        let open = UNNotificationAction(identifier: "Open App", title: "Open App", options: [])

        let category = UNNotificationCategory(identifier: "CustomCategory", actions: [snooze, open], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)

        

        let calendar = Calendar.current

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        

        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)

        

        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.setNotificationCategories([category])

        notificationCenter.add(request) { error in

            if let error = error {

                print("Error scheduling notification: \(error.localizedDescription)")

            } else {

                print("Notification scheduled successfully")

            }

        }

    }

}





//for in app interaction





// NotificationDelegate.swift

import Foundation

import UserNotifications



class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.badge, .banner, .sound])

    }

}
