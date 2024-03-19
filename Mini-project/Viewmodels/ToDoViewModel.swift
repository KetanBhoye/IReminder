import Foundation

class TodoListViewModel: ObservableObject {
   
    
    
    @Published var tasks: [Task] = []
    var notification = NotificationManager.instance
    init() {
        loadTasks()
        
    }

    func addTask(_ task: Task) {
        let notificationTitle = task.title
        let notificationBody = task.description
        let notificationDate = task.dueDate // 40 seconds from now

        notification.scheduleNotification(title: notificationTitle, body: notificationBody, date: notificationDate, id: task.id)

        tasks.append(task)
        saveTasks()
    }

     func saveTasks() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(tasks)
            UserDefaults.standard.set(data, forKey: "YourAppIdentifier.Tasks")
        } catch {
            print("Error encoding tasks: \(error)")
        }
    }
    
    
    func removeTasks(at indices: IndexSet) {
            tasks.remove(atOffsets: indices)
            saveTasks()
        }

     func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "YourAppIdentifier.Tasks") {
            do {
                let decoder = JSONDecoder()
                let loadedTasks = try decoder.decode([Task].self, from: data)
                tasks = loadedTasks
            } catch {
                print("Error decoding tasks: \(error)")
            }
        }
    }
}
