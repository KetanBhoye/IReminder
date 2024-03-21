import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import UserNotifications
import Contacts

@main
struct Mini_projectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            LoginSignUpView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let todolistviewmodel = TodoListViewModel()
    @State var selectedTab: BottomBarSelectedTab = .profile

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self // Set the delegate for handling notifications
        return true
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // Implement delegate method to handle notifications when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let identifier = notification.request.identifier

        if identifier == "callnotconn" {
            print("Notification Title: \(notification.request.content.title)")
        }

        completionHandler([.banner, .sound, .badge]) // You can adjust the options based on your requirements
    }

    // Implement delegate method to handle user's interaction with notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier

        switch identifier {
        case "keyboardReminder_meet":
            print("User clicked on keyboardReminder_meet notification")
            // Code to open MeetingReminderInputView
            let rootViewController = UIApplication.shared.windows.first?.rootViewController
            let addView = AddView(selectedReminderType: 1, todo: Task(type: 2, contact: ContactInfo(firstName: "name", lastName: "name")), todolistviewmodel: todolistviewmodel, selectedTab: $selectedTab)
            rootViewController?.present(UIHostingController(rootView: addView), animated: true)

        case "keyboardReminder_call":
            print("User clicked on keyboardReminder_call notification")
            // Code to open CallReminderInputView
            let rootViewController = UIApplication.shared.windows.first?.rootViewController
            let addView = AddView(selectedReminderType: 2,todo: Task(type: 3, contact: ContactInfo(firstName: "name", lastName: "name")), todolistviewmodel: todolistviewmodel, selectedTab: $selectedTab)
            rootViewController?.present(UIHostingController(rootView: addView), animated: true)

        case "keyboardReminder_birthday":
            print("User clicked on keyboardReminder_birthday notification")
            // Code to open BirthdayReminderInputView
            let rootViewController = UIApplication.shared.windows.first?.rootViewController
            let addView = AddView(selectedReminderType: 0,todo: Task(type: 1, contact: ContactInfo(firstName: "name", lastName: "name")), todolistviewmodel: todolistviewmodel, selectedTab: $selectedTab)
            rootViewController?.present(UIHostingController(rootView: addView), animated: true)

        default:
            print("User clicked on a notification with an unrecognized identifier")
        }

        // Call the completion handler when finished processing the notification
        completionHandler()
    }
}
