//
//  AddView.swift
//  Mini-project
//
//  Created by mini project on 07/02/24.
//

import SwiftUI

struct AddView: View {
    @State var todo : Task
    @State var contact : ContactInfo = ContactInfo(firstName: "Jon", lastName:"Doe")
    @State private var isHovered = false
    @ObservedObject var todolistviewmodel : TodoListViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var selectedTab : BottomBarSelectedTab
    
    
    // Function to save tasks to UserDefaults

    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            HStack(){
                Spacer()
                Text("Add ToDo").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).foregroundStyle(Color.blue).shadow(radius: 10).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                Spacer()
            }.padding(.top , 20.0)
            Text("Title")
                .padding(.horizontal)
            TextField("Title", text: $todo.title)
                .padding(.horizontal)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Description")
                .padding(.horizontal)
            TextField("Description", text: $todo.description)
                .padding(.horizontal)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            DatePicker("Schedule", selection: $todo.dueDate, in: Date()..., displayedComponents: [.date , .hourAndMinute])
                .padding()
            
            //            if let phoneNumber = contact?.phoneNumber?.stringValue {
            //                Text("Contact: \(phoneNumber)")
            //                    .padding(.horizontal)
            if !((contact.phoneNumber?.stringValue) == nil) {
                HStack{
                    Spacer()
                    VStack(alignment: .leading, spacing: 10) {
                        
                        HStack{
                            Spacer()
                            Text("Contact Information")
                                .font(.headline).underline()
                            Spacer()
                        }
                        
                        
                        Text("First Name: \(contact.firstName)")
                        Text("Last Name: \(contact.lastName)")
                        if let phoneNumber = contact.phoneNumber?.stringValue {
                            Text("Phone Number: \(phoneNumber)")
                        }
                        Button("Click here to edit contact"){
                            isHovered.toggle()
                        }.sheet(isPresented: $isHovered){
                            ContactView(contactObj:$contact)
                        }
//                        NavigationLink("Click here to edit contact", destination: ContactView(contactObj:$contact))
//                            .padding(.horizontal)
                            
                    }
                    .padding().background(Color(red: 255/255.0, green: 246/255.0, blue: 233/255.0)).cornerRadius(7.0)
                Spacer()
                }
                
            } else{
               
                        HStack {
                            Spacer()
                            Image(systemName: "person.crop.circle.badge.plus").font(.largeTitle)
                            
                            Button("Add Contact"){
                                isHovered.toggle()
                            }.sheet(isPresented: $isHovered){
                                ContactView(contactObj:$contact)
                            }
//                                .onTapGesture {
////                                    NavigationLink("Add Contact", destination: ContactView(contactObj:$contact))
////                                        .padding(.horizontal).font(.title2)
////                                    Spacer()
//                                    
//                                    
//                                }.sheet(item: <#T##Binding<Identifiable?>#>, content: <#T##(Identifiable) -> View#>)
                            Spacer()
                            
                            
                        }
                        
            }
            Spacer()
            
            HStack{
                Spacer()
                Button(action: {
                    print(contact)
                    print(todo)
                    todo.contact = contact
                    todolistviewmodel.addTask(todo)
                    print("after adding",todo)
                    // Save tasks through the view model
                    todolistviewmodel.saveTasks()
                    print("before wrap")
                    if selectedTab == .plus{
                        selectedTab = .home
                    }
                    else{
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        
                        Text("Add ToDo Item")
                            .padding(.horizontal)
                        
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10).bold().tracking(2.0)
                }
                .padding()
                Spacer()
            }
            Spacer()
        }.navigationBarTitleDisplayMode(.inline)
    }}

//#Preview {
//    NavigationView {
//        @State var selected = BottomBarSelectedTab(rawValue: 0)
//        AddView( todo: Task(contact: ContactInfo(firstName: "test", lastName: "test")), todolistviewmodel: TodoListViewModel(), selectedTab: $selected)
//    }
//    
//}

