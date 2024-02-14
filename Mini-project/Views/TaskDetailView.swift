import SwiftUI

struct TaskDetailView: View {
    var task: Task

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Title: \(task.title)")
                .font(.headline)
            Text("Description: \(task.description)")
            Text("Due Date: \(task.dueDate, style: .date)")
            
            if let contact = task.contact {
                Text("Contact Information:")
                Text("Name: \(task.contact!.firstName) \(task.contact!.lastName)")
//                Text("Last Name: \(task.contact!.lastName)")
                if let phoneNumber = contact.phoneNumber?.stringValue {
                    Text("Phone Number: \(phoneNumber)")
                }
            }
        }
        .padding()
        .navigationTitle(task.title)
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
