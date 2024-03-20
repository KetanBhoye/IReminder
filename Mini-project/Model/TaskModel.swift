import Foundation
import Contacts

struct Task: Identifiable, Codable {
    var id = UUID()
    var type: Int
    var title: String
    var description: String
    var link: String
    var mail: String
    var dueDate: Date
    var isCompleted: Bool
    var reminderDate: Date?
    var contact: ContactInfo?

    init(
        type: Int = 0,
        title: String = "",
        description: String = "",
        link: String = "",
        mail: String = "",
        dueDate: Date = Date(),
        isCompleted: Bool = false,
        reminderDate: Date? = nil,
        contact: ContactInfo? = nil
    ) {
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.reminderDate = reminderDate
        self.contact = contact
        self.type = type
        self.link = link
        self.mail = mail
        
    }
}

struct PhoneNumber: Codable, Equatable, Hashable {
    var stringValue: String

    init(stringValue: String) {
        self.stringValue = stringValue
    }
}

struct ContactInfo: Identifiable, Codable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var phoneNumber: PhoneNumber?

    init(firstName: String, lastName: String, phoneNumber: PhoneNumber? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
    }
}








//import Foundation
//import Contacts
//
//struct Task: Identifiable, Codable {
//    var id = UUID()
//    var title: String
//    var description: String
//    var dueDate: Date
//    var isCompleted: Bool
//    var reminderDate: Date?
//    var contact: ContactInfo?
//
//    init(
//        title: String = "",
//        description: String = "",
//        dueDate: Date = Date(),
//        isCompleted: Bool = false,
//        reminderDate: Date? = nil,
//        contact: ContactInfo? = nil
//    ) {
//        self.title = title
//        self.description = description
//        self.dueDate = dueDate
//        self.isCompleted = isCompleted
//        self.reminderDate = reminderDate
//        self.contact = contact
//    }
//}
//
//struct PhoneNumber: Codable, Equatable, Hashable {
//    var stringValue: String
//
//    init(stringValue: String) {
//        self.stringValue = stringValue
//    }
//}
//
//struct ContactInfo: Identifiable, Codable {
//    var id = UUID()
//    var firstName: String
//    var lastName: String
//    var phoneNumber: PhoneNumber?
//
//    init(firstName: String, lastName: String, phoneNumber: PhoneNumber? = nil) {
//        self.firstName = firstName
//        self.lastName = lastName
//        self.phoneNumber = phoneNumber
//    }
//}
