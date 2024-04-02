import Foundation
import Contacts

import UserNotifications



class TodoListViewModel: ObservableObject {

    @Published var tasks: [Task] = []

    var notification = NotificationManager.instance

    

    init() {

        loadTasks()

        let notificationDelegate = NotificationDelegate()

        UNUserNotificationCenter.current().delegate = notificationDelegate

    }

    

    func addTask(_ task: Task) {

        let notificationTitle = task.title

        let notificationBody = task.description
        
//        print("this is add task");
//        print(task.type)
        

        if let notificationDate = task.reminderDate {

            notification.scheduleNotification(title: notificationTitle, body: notificationBody, date: notificationDate, id: task.id,task: task)

        } else {

            // Handle case where reminderDate is nil

        }

        

        tasks.append(task)

        saveTasks()

    }

    func saveTasks() {

        do {

            let encoder = JSONEncoder()

            let data = try encoder.encode(tasks)

            UserDefaults.standard.set(data, forKey: Bundle.main.bundleIdentifier ?? "YourAppIdentifier.Tasks")

        } catch {

            print("Error encoding tasks: \(error)")

        }

    }

    

    func removeTasks(at indices: IndexSet) {

        tasks.remove(atOffsets: indices)

        saveTasks()

    }

    

    func loadTasks() {

        if let data = UserDefaults.standard.data(forKey: Bundle.main.bundleIdentifier ?? "YourAppIdentifier.Tasks") {

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
