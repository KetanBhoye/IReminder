import SwiftUI
import Foundation
import UIKit

struct TaskDetailView: View {
    var task: Task

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Text(task.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                if !task.description.isEmpty {
                    VStack(alignment: .center, spacing: 10) { // Align center
                        Text("Description")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        Text(task.description)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                VStack(alignment: .center, spacing: 10) { // Align center
                    Text("Due Date")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    Text(task.dueDate, style: .date)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                // Display view based on Reminder Type
                switch task.type {
                case 1:
                    BirthdayView(task: task)
                case 2:
                    MeetingView(task: task)
                case 3:
                    CallView(task: task)
                case 4:
                    CustomView(task: task)
                default:
                    Text("Invalid task type")
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Task Details")
        .onAppear(perform: {
            print(task)
        })
    }
}

// Separate View for Birthday Task
struct BirthdayView: View {
    var task: Task
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Birthday Details")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            if let contact = task.contact {
                VStack(alignment: .center, spacing: 5) {
                    Text("Happy Birthday \(contact.firstName)")
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Spacer()
                    Text("Contact Details")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Text("First Name: \(contact.firstName)")
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Text("Last Name: \(contact.lastName)")
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
            }
            Spacer()
            Button(action: {
                // Action to wish birthday
            }) {
                Text("Wish Birthday")
                    .foregroundColor(.black)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
            }
        }
        .frame(maxWidth: .infinity)
        
    }
}

// Separate View for Meeting Task
struct MeetingView: View {
    var task: Task
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            if !task.link.isEmpty {
                VStack(alignment: .center, spacing: 5) {
                    Text("Meeting Link")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Text(task.link)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
            }
            
            if !task.mail.isEmpty {
                VStack(alignment: .center, spacing: 5) {
                    Text("Email")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Text(task.mail)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
            }
            Spacer()
            Button(action: {
                // Action to send email to participants
            }) {
                Text("Send Email to Participants")
                    .foregroundColor(.black)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Separate View for Call Task

struct CallView: View {
    var task: Task
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Call Details")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            if let contact = task.contact {
                VStack(alignment: .center, spacing: 5) {
                    Text("First Name: \(contact.firstName)")
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Text("Last Name: \(contact.lastName)")
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    if let phoneNumber = contact.phoneNumber?.stringValue, !phoneNumber.isEmpty {
                        Text("Phone Number: \(phoneNumber)")
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            Spacer()
            Button(action: {
                if let phoneNumber = task.contact?.phoneNumber?.stringValue, !phoneNumber.isEmpty {
                    guard let number = URL(string: "tel://" + phoneNumber) else { return }
                    UIApplication.shared.open(number)
                }
            }) {
                Text("Call \(task.contact?.firstName ?? "Contact")")
                    .foregroundColor(.black)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
            }
        }
        .frame(maxWidth: .infinity)
    }
}


// Separate View for Custom Task
struct CustomView: View {
    var task: Task
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
//            Text("Custom Task Details")
//                .font(.headline)
//                .fontWeight(.bold)
//                .foregroundColor(.black)
//                .multilineTextAlignment(.center)
            
            if !task.link.isEmpty {
                VStack(alignment: .center, spacing: 5) {
                    Text("Event Link")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Text(task.link)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Preview
struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailView(task: Task(
            title: "Sample Task",
            description: "This is a sample task description.",
            dueDate: Date(),
            contact: ContactInfo(firstName: "John", lastName: "Doe", phoneNumber: PhoneNumber(stringValue: "1234567890"))
        ))
    }
}
