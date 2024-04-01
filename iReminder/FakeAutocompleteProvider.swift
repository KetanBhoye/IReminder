//
//  FakeAutocompleteProvider.swift
//  Keyboard
//
//  Created by Daniel Saidi on 2022-02-07.
//  Copyright © 2022-2024 Daniel Saidi. All rights reserved.
//

import Foundation
import KeyboardKit
import UserNotifications
import Contacts
/**
 This fake autocomplete provider is used in the non-pro demo,
 to show fake suggestions while typing.
 */

class NotificationManager {
    static let shared = NotificationManager()
    
    var etc = KeyboardViewController()
    
    private let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    
    private init() {}
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if granted {
                print("Notification authorization granted.")
            } else {
                print("Notification authorization denied.")
            }
        }
    }
    
    func scheduleNotification(type: String, contactName: String?, contactNumber: String?) {
        let content = UNMutableNotificationContent()
        content.title = "iReminder"
        
        // Customize notification based on type
        switch type {
        case "call":
            if let contactName = contactName, !contactName.isEmpty {
                content.body = "Call \(contactName) at \(contactNumber ?? "their number")"
            } else {
                content.body = "Call reminder"
            }
        case "meet":
            content.body = "Meeting reminder"
        case "birthday":
            content.body = "Birthday reminder"
        default:
            content.body = "Reminder"
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "keyboardReminder_\(type)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }

}



class FakeAutocompleteProvider: AutocompleteProvider {
    
    init(context: AutocompleteContext) {
        self.context = context
        NotificationManager.shared.requestNotificationAuthorization()
    }
    
    private var context: AutocompleteContext
    private var contactStore = CNContactStore()
    
    var locale: Locale = .current
    var canIgnoreWords: Bool { false }
    var canLearnWords: Bool { false }
    var ignoredWords: [String] = []
    var learnedWords: [String] = []
    
    func hasIgnoredWord(_ word: String) -> Bool { false }
    func hasLearnedWord(_ word: String) -> Bool { false }
    func ignoreWord(_ word: String) {}
    func learnWord(_ word: String) {}
    func removeIgnoredWord(_ word: String) {}
    func unlearnWord(_ word: String) {}
    
    func autocompleteSuggestions(for text: String) async throws -> [Autocomplete.Suggestion] {
        guard text.count > 0 else { return [] }
        
        // Check if text starts with "@" and extract the name
        if text.first == "@" {
            let namePrefix = String(text.dropFirst())
            let contacts = try getMatchingContacts(for: namePrefix)
            return contacts.map { Autocomplete.Suggestion(text: $0.fullName, subtitle: $0.contactNumber) }
        }
        
        //print("User typed: \(text)")
        
        if text == "🙂" {
//            KeyboardViewController.showemojikeyboard.toggle()
                   // Present emoji keyboard
            
               }
        
        let suggestions = fakeSuggestions(for: text)
        
        // Schedule notification based on user's typing
        if text.lowercased().hasPrefix("call") {
            let name = text.components(separatedBy: "@").last?.trimmingCharacters(in: .whitespacesAndNewlines)
            let contactNumber = suggestions.first?.subtitle ?? ""
            NotificationManager.shared.scheduleNotification(type: "call", contactName: name, contactNumber: contactNumber)
        } else if text.lowercased() == "meet" || text.lowercased() == "birthday" {
            NotificationManager.shared.scheduleNotification(type: text.lowercased(), contactName: nil, contactNumber: nil)
        }
        
        return suggestions.map {
            var suggestion = $0
            suggestion.isAutocorrect = $0.isAutocorrect && context.isAutocorrectEnabled
            return suggestion
        }
    }

    
    private func getMatchingContacts(for namePrefix: String) throws -> [(fullName: String, contactNumber: String)] {
        var matchingContacts: [(fullName: String, contactNumber: String)] = []
        
        let predicate = CNContact.predicateForContacts(matchingName: namePrefix)
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        
        for contact in contacts {
            let fullName = "\(contact.givenName) \(contact.familyName)"
            if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                matchingContacts.append((fullName, phoneNumber))
            } else {
                matchingContacts.append((fullName, ""))
            }
        }
        
        return matchingContacts
    }
}

private extension FakeAutocompleteProvider {
    func fakeSuggestions(for text: String) -> [Autocomplete.Suggestion] {
        [
            .init(text: text, isUnknown: true),
            .init(text: text, isAutocorrect: true),
            .init(text: text, subtitle: "Subtitle")
        ]
    }
}


