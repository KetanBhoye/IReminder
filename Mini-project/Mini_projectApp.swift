//
//  Mini_projectApp.swift
//  Mini-project
//
//  Created by mini project on 05/02/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

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
    @ObservedObject var todolistviewmodel = TodoListViewModel()
    
    @State var selectedTab:BottomBarSelectedTab = .home
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self // Set the delegate for handling notifications
        return true
    }

    private func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: [String : Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // Handle notifications when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle notification as needed, e.g., show an alert
        // You can customize this part based on your app's behavior
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notifications when the app is in the background or terminated
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification action here
        // You can navigate to the addTaskView or perform any other action
        
        // Example:
        if response.notification.request.identifier == "keyboardReminder" {
            // Navigate to the addTaskView
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = UIHostingController(rootView: AddView( todo: Task(contact: ContactInfo(firstName: "name", lastName: "name")), todolistviewmodel: todolistviewmodel,  selectedTab: $selectedTab))
            }
        }
        
        completionHandler()
    }
}



