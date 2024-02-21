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
            if let err = error {
                print (error)
            }
            else {
                print(success)
            }
        }
    }
    
    
}
