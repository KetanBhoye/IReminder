//
//  AddTaskView.swift
//  Mini-project
//
//  Created by mini project on 08/02/24.
//

import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var todolistviewmodel : TodoListViewModel
    @State private var newTask : Task?
    
    
                

    var body: some View {
        VStack {
            Text("details")
        }
        .padding()
        .navigationTitle("Add Task")
    }
}
#Preview {
    AddTaskView()
}
