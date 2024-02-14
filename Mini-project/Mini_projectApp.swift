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
       
        WindowGroup{
            LoginSignUpView()
        }
           
        
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }

    private func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: [String : Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
}




