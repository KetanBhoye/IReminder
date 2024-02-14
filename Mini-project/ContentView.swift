//
//  ContentView.swift
//  BottomBar
//
//  Created by Hitesh Thummar on 03/10/23.
//

import SwiftUI


struct ContentView: View {
    
    @State var contact : ContactInfo = ContactInfo(firstName: "Vijay", lastName: "Mali")
    @ObservedObject var todolistviewmodel = TodoListViewModel()
    
    @State var selectedTab:BottomBarSelectedTab = .home
    var body: some View {
        VStack {
            if selectedTab == .home{
                TodoListView()
//                Text("Home")
            }
            
            if selectedTab == .search{
                ContactView(contactObj: $contact)
//                Text("Search")
            }
            
            if selectedTab == .plus{
                AddView( todo: Task(contact: ContactInfo(firstName: "name", lastName: "name")), todolistviewmodel: todolistviewmodel,  selectedTab: $selectedTab)
                Text("Add")
            }
            if selectedTab == .notification{
                MissedCallsView()
            }
            if selectedTab == .profile{
                ProfileView()
//                Text("Profile")
            }
            Spacer()
            BottomBar(selectedTab: $selectedTab)
        }
        .environmentObject(todolistviewmodel)
        .navigationBarBackButtonHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

