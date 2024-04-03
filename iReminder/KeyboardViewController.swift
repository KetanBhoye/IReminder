//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Daniel Saidi on 2021-02-11.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

import KeyboardKit
import SwiftUI
import Contacts
import UserNotifications

struct ContactListView: View {
    var contacts: [String] // Assuming contacts are represented by strings
    var didSelectContact: (String) -> Void // Callback to handle contact selection

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(contacts, id: \.self) { contact in
                    Button(action: {
                        didSelectContact(contact)
                    }) {
                        Text(contact)
                            .padding(8)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
}


/**
 This keyboard demonstrates how to setup KeyboardKit and how
 to customize the standard configuration.

 To use this keyboard, you must enable it in system settings
 ("Settings/General/Keyboards"). It needs full access to get
 access to features like haptic feedback.
 */
class KeyboardViewController: KeyboardInputViewController, FakeAutocompleteProviderDelegate {

    @State var showemojikeyboard = false
    var contacts = [String]() // Will hold the fetched contacts data
     var searchText = ""
     var typetext = ""
    
    

    
    func didChangeText(_ searchText: String) {
        var filteredSearchText = searchText
        
        if filteredSearchText.lowercased().starts(with: "call@") {
            typetext = String(filteredSearchText.dropLast(filteredSearchText.count-4))
            filteredSearchText = String(filteredSearchText.dropFirst(5))
        }
        if filteredSearchText.lowercased().starts(with: "meet@") {
            typetext = String(filteredSearchText.dropLast(filteredSearchText.count-4))
            filteredSearchText = String(filteredSearchText.dropFirst(5))
        }
        if filteredSearchText.lowercased().starts(with: "birthday@") {
            typetext = String(filteredSearchText.dropLast(filteredSearchText.count-8))
            filteredSearchText = String(filteredSearchText.dropFirst(9))
        }
        if filteredSearchText.lowercased().starts(with: "@") {
            typetext = String(filteredSearchText.dropLast(filteredSearchText.count-1))
           
        }

        
        self.searchText = filteredSearchText
        
        do {
                contacts = try getMatchingContacts(searchText: filteredSearchText)
        } catch {
            print("Error fetching matching contacts: \(error.localizedDescription)")
        }
        
        print(searchText)
        print("typetext\(typetext)")
        print(contacts)
    }
    
    func requestNotificationAuthorization() {
         UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
             if granted {
                 print("Notification authorization granted.")
             } else {
                 print("Notification authorization denied.")
             }
         }
     }
    
    func scheduleNotification(type: String, contact: String) {
          let content = UNMutableNotificationContent()
          content.title = "iReminder"
          content.userInfo = ["contact": contact]
        


          // Customize notification based on type
          switch type {
          case "call":
              content.body = "Call reminder"
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

    // Search for contact with the given name
    func findContact(withName name: String) -> String? {
        let contactStore = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let predicate = CNContact.predicateForContacts(matchingName: name)
        
        do {
            let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys)
            if let contact = contacts.first {
                if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                    return phoneNumber
                }
            }
        } catch {
            print("Error fetching contact: \(error.localizedDescription)")
        }
        
        return nil
    }

    
    /// This function is called when the controller loads.
    ///
    /// Here, we make demo-specific service keyboard configs.
    override func viewDidLoad() {
      
    
            print(contacts)
        
        /// 💡 Setup a demo-specific action handler.
        ///
        /// The demo handler has custom code for tapping and
        /// long pressing image actions.
        ///
        // Request notification authorization
                requestNotificationAuthorization()
        
        services.actionHandler = DemoActionHandler(
                controller: self,
                keyboardContext: state.keyboardContext,
                keyboardBehavior: services.keyboardBehavior,
                autocompleteContext: state.autocompleteContext,
                feedbackConfiguration: state.feedbackConfiguration,
                spaceDragGestureHandler: services.spaceDragGestureHandler)
        
        /// 💡 Setup a fake autocomplete provider.
        ///
        /// This fake provider will provide fake suggestions.
        /// Try the Pro demo for real suggestions.
        services.autocompleteProvider = FakeAutocompleteProvider(
            context: state.autocompleteContext
        )
        
        /// 💡 Setup a demo-specific callout action provider.
        ///
        /// The demo provider adds "keyboard" callout action
        /// buttons to the "k" key.
        services.calloutActionProvider = StandardCalloutActionProvider(
            keyboardContext: state.keyboardContext,
            baseProvider: DemoCalloutActionProvider())
        
        /// 💡 Setup a demo-specific layout provider.
        ///
        /// The demo provider adds a "next locale" button if
        /// needed, as well as a rocket emoji button.
        services.layoutProvider = DemoLayoutProvider()
        
        /// 💡 Setup a demo-specific style provider.
        ///
        /// The demo provider styles the rocket emoji button
        /// and has some commented out code that you can try.
        services.styleProvider = DemoStyleProvider(
            keyboardContext: state.keyboardContext)
        

        /// 💡 Setup a custom keyboard locale.
        ///
        /// Without KeyboardKit Pro, changing locale will by
        /// default only affects localized texts.
        state.keyboardContext.setLocale(.english)

        /// 💡 Add more locales to the keyboard.
        ///
        /// The demo layout provider will add a "next locale"
        /// button if you have more than one locale.
        state.keyboardContext.localePresentationLocale = .current
        state.keyboardContext.locales = [] // KeyboardLocale.all.locales
        
        /// 💡 Setup a custom dictation key replacement.
        ///
        /// Since dictation is not available by default, the
        /// dictation button is removed if we don't set this.
        state.keyboardContext.keyboardDictationReplacement = .character("😀")
        
        /// 💡 Configure the space long press behavior.
        ///
        /// The locale context menu will only open up if the
        /// keyboard has multiple locales.
        state.keyboardContext.spaceLongPressBehavior = .moveInputCursor
        // state.keyboardContext.spaceLongPressBehavior = .openLocaleContextMenu
        
        /// 💡 Setup audio and haptic feedback.
        ///
        /// The code below enabled haptic feedback and plays
        /// a rocket sound when a rocket button is tapped.
        state.feedbackConfiguration.isHapticFeedbackEnabled = true
        state.feedbackConfiguration.audio.actions = [
            .init(action: .character("🙂"), feedback: .none)
        ]
        
        
        // state.feedbackConfiguration.disableAudioFeedback()
        // state.feedbackConfiguration.disableHapticFeedback()
        
        /// 💡 Call super to perform the base initialization.
        super.viewDidLoad()
        
        let autocompleteProvider = FakeAutocompleteProvider(context: state.autocompleteContext)
            autocompleteProvider.delegate = self
            services.autocompleteProvider = autocompleteProvider
        
        
        
    }
    
    private func getMatchingContacts(searchText: String) throws -> [String] {
        var matchingContacts: [String] = []
        var count = 0

        let predicate = CNContact.predicateForContacts(matchingName: searchText)
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]

        let contactStore = CNContactStore()
        let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)

        for contact in contacts {
            if count < 10 {
                let fullName = "\(contact.givenName) \(contact.familyName)"
                matchingContacts.append(fullName)
                count += 1
            } else {
                break // Stops iteration once 10 matching contacts are fetched
            }
        }

        return matchingContacts
    }



    /// This function is called whenever the keyboard should
    /// be created or updated.
    ///
    /// Here, we just create a standard system keyboard like
    /// the library does it, just to show how it's done. You
    /// can customize anything you want.
    ///
    ///
    
    
    
    override func viewWillSetupKeyboard() {
        super.viewWillSetupKeyboard()

        /// 💡 Make the demo use a standard ``SystemKeyboard``.
        setup { controller in
            SystemKeyboard(
                state: controller.state,
                services: controller.services,
                buttonContent: { $0.view },
                buttonView: { $0.view.scaleEffect(0.70) },
                emojiKeyboard: { $0.view },
                toolbar: {_ in 
                    HStack {
                        
                        
                        Button(action: {
                            self.presentEmojiKeyboard()
                        }) {
                            Text("🙂")
                        }
                        Spacer()
                            
                        ContactListView(contacts: self.contacts) { [self] contact in
                            if !typetext.isEmpty {
                                if(typetext=="@"){
                                    
                                                    
                                                 // Insert the phone number after "@"
                                    textDocumentProxy.deleteBackward(times: 50)
                                    if let phoneNumber = findContact(withName: contact) {
                                        textDocumentProxy.insertText(phoneNumber)
                                    }
                                    
                                
                                    
                                    
//

                                }
                                else{
                                    scheduleNotification(type: typetext.lowercased(), contact: contact)
                                    print("Selected contact: \(contact)")
                                }
                            }
                          
                                
                            }
                       
                    }.padding(5)
                    
                   

                }
            )
            // .autocorrectionDisabled()
        }
    }
    
    
}

// MARK: - EmojiKeyboard Integration
