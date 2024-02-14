import SwiftUI

struct TodoListView: View {
    @ObservedObject var todolistviewmodel = TodoListViewModel()

    var body: some View {
        NavigationView {
            VStack {
                List(todolistviewmodel.tasks, id: \.id) { task in
                    NavigationLink(destination: TaskDetailView(task: task)) {
                        Text(task.title)
                    }
                }
            }
            .navigationTitle("Dashboard ")
            .navigationBarItems(trailing:
                NavigationLink(destination: AddView(todo: Task(contact: ContactInfo(firstName: "name", lastName: "name")), todolistviewmodel: todolistviewmodel)) {
                    Image(systemName: "plus")
                }
            )
            .onAppear(perform: {
                todolistviewmodel.loadTasks()
            })
        }
        .environmentObject(todolistviewmodel)
        .edgesIgnoringSafeArea(.all)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}
