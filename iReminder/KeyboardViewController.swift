import UIKit
import UserNotifications

class KeyboardViewController: UIInputViewController {
    var inpString: String = ""
    var letterButtons = [UIButton]()
    var isCapsLockEnabled = false
    var isExtendedKeyboardEnabled = false
    var deleteTimer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()

        let buttonTitles = [
            ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
            ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
            ["a", "s", "d", "f", "g", "h", "j", "k", "l", "⬆️"],
            ["z", "x", "c", "v", "b", "n", "m", "-", "⏪"],
            ["!#1","🙂", "space", ".", ",", "⮐"]
        ]

        // Define button size and spacing constants
        let buttonWidth: CGFloat = 30 // Adjust button width as needed
        let buttonHeight: CGFloat = 30 // Adjust button height as needed
        let horizontalSpacing: CGFloat = 5 // Adjust horizontal spacing as needed
        let verticalSpacing: CGFloat = 2 // Adjust vertical spacing as needed
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(backspaceLongPressed(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.2// Adjust as needed
        view.addGestureRecognizer(longPressGestureRecognizer)

        // Loop through button titles to create buttons
        for (rowIndex, rowTitles) in buttonTitles.enumerated() {
            for (colIndex, title) in rowTitles.enumerated() {
                let button = UIButton(type: .system)
                button.setTitle(title, for: [])
                button.sizeToFit()
                button.translatesAutoresizingMaskIntoConstraints = false
                button.layer.cornerRadius = 5
                button.backgroundColor = UIColor(white: 0.9, alpha: 1.0) // Adjust color as needed
                button.addTarget(self, action: #selector(letterTapped(_:)), for: .touchUpInside)
                view.addSubview(button)
                letterButtons.append(button)

                // Add constraints for rows and columns
                NSLayoutConstraint.activate([
                    button.topAnchor.constraint(equalTo: view.topAnchor, constant: CGFloat(rowIndex) * (buttonHeight + verticalSpacing) + 20),
                    button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(colIndex) * (buttonWidth + horizontalSpacing) + 20),
                    button.widthAnchor.constraint(equalToConstant: buttonWidth),
                    button.heightAnchor.constraint(equalToConstant: buttonHeight)
                ])
            }
        }

        // Request notification authorization
        requestNotificationAuthorization()
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

    func scheduleNotification(type: String) {
        let content = UNMutableNotificationContent()
        content.title = "iReminder"
        
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
        
        // Use a unique identifier based on the type of reminder
        let identifier = "keyboardReminder"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }
    @objc func backspaceLongPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            deleteTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(deleteCharacter), userInfo: nil, repeats: true)
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            deleteTimer?.invalidate()
            deleteTimer = nil
        }
    }

    @objc func deleteCharacter() {
        if !inpString.isEmpty {
            inpString.removeLast()
            textDocumentProxy.deleteBackward()
        }
    }

    @objc func letterTapped(_ sender: UIButton) {
        guard let letter = sender.title(for: .normal) else { return }

        if letter == "⏪" {
            if textDocumentProxy.hasText {
                if !inpString.isEmpty{
                    inpString.removeLast()
                }
                
                textDocumentProxy.deleteBackward()
                
            }
        } else if letter == "⬆️" {
            // Toggle caps lock
            isCapsLockEnabled.toggle()
            updateKeyboardLayout()
        } else if letter == "!#1" || letter == "ABC" {
            // Toggle extended keyboard
            isExtendedKeyboardEnabled.toggle()
            updateKeyboardLayout()
        } else if letter == "space" {
            textDocumentProxy.insertText(" ")
        } else if letter == "⮐" {
            textDocumentProxy.insertText("\n")
        } else {
            var characterToAdd = ""
            if isCapsLockEnabled {
                characterToAdd = letter.uppercased()
            } else if isExtendedKeyboardEnabled {
                characterToAdd = getExtendedCharacter(for: letter)
            } else {
                characterToAdd = letter.lowercased()
            }
            textDocumentProxy.insertText(characterToAdd)
            inpString += characterToAdd

            // Check if 'todo:' is typed
            if inpString.hasPrefix("todo:") {
                // Check for specific types
//                if inpString.hasSuffix("call") {
//                    scheduleNotification(type: "call")
//                } else if inpString.hasSuffix("meet") {
//                    scheduleNotification(type: "meet")
//                } else if inpString.hasSuffix("birthday") {
//                    scheduleNotification(type: "birthday")
//                }
                scheduleNotification(type: "call")
            }
        }

        // Print the tapped letter
        print("Letter tapped: \(inpString)")
    }

    func updateKeyboardLayout() {
        // Update keyboard layout to reflect caps lock state
        for button in letterButtons {
            if let title = button.title(for: .normal) {
                var updatedTitle = ""
                if title == "!#1" || title == "ABC" {
                    updatedTitle = isExtendedKeyboardEnabled ? "ABC" : "!#1"
                } else {
                    updatedTitle = isCapsLockEnabled ? title.uppercased() : title.lowercased()
                }
                button.setTitle(updatedTitle, for: .normal)
            }
        }
        
        // Update letter buttons for extended keyboard
        if isExtendedKeyboardEnabled {
            for (index, button) in letterButtons.enumerated() {
                let title = getExtendedCharacter(for: button.title(for: .normal)!)
                button.setTitle(title, for: .normal)
            }
        } else {
            // Restore original letters for regular keyboard layout
            for (index, button) in letterButtons.enumerated() {
                let title = getRegularCharacter(for: button.title(for: .normal)!)
                button.setTitle(title, for: .normal)
            }
        }
    }


    func getExtendedCharacter(for letter: String) -> String {
        switch letter {
        case "1":
            return "!"
        case "2":
            return "@"
        case "3":
            return "#"
        case "4":
            return "$"
        case "5":
            return "%"
        case "6":
            return "^"
        case "7":
            return "&"
        case "8":
            return "*"
        case "9":
            return "("
        case "0":
            return ")"
        case "q":
            return "_"
        case "w":
            return "+"
        case "e":
            return "`"
        case "r":
            return "-"
        case "t":
            return "="
        case "y":
            return "{"
        case "u":
            return "}"
        case "i":
            return "|"
        case "o":
            return "["
        case "p":
            return "]"
        case "a":
            return "\\"
        case "s":
            return ":"
        case "d":
            return ";"
        case "f":
            return "'"
        case "g":
            return ","
        case "h":
            return "."
        case "j":
            return "/"
        case "k":
            return "<"
        case "l":
            return ">"
        case "z":
            return "?"
        case "x":
            return "~"
        case "c":
            return "¨"
        case "v":
            return "½"
        case "b":
            return "×"
        case "n":
            return "÷"
        case "m":
            return "€"
        default:
            return letter
        }
    }
    
    func getRegularCharacter(for letter: String) -> String {
        switch letter {
        case "!":
            return "!#1"
        case "@":
            return "2"
        case "#":
            return "3"
        case "$":
            return "4"
        case "%":
            return "5"
        case "^":
            return "6"
        case "&":
            return "7"
        case "*":
            return "8"
        case "(":
            return "9"
        case ")":
            return "0"
        case "_":
            return "q"
        case "+":
            return "w"
        case "`":
            return "e"
        case "-":
            return "r"
        case "=":
            return "t"
        case "{":
            return "y"
        case "}":
            return "u"
        case "|":
            return "i"
        case "[":
            return "o"
        case "]":
            return "p"
        case "\\":
            return "a"
        case ":":
            return "s"
        case ";":
            return "d"
        case "'":
            return "f"
        case ",":
            return "g"
        case ".":
            return "h"
        case "/":
            return "j"
        case "<":
            return "k"
        case ">":
            return "l"
        case "?":
            return "z"
        case "~":
            return "x"
        case "¨":
            return "c"
        case "½":
            return "v"
        case "×":
            return "b"
        case "÷":
            return "n"
        case "€":
            return "m"
        default:
            return letter
        }
    }
}
