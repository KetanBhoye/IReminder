import UIKit
import UserNotifications

class KeyboardViewController: UIInputViewController {
    var inpString: String = ""
    var letterButtons = [UIButton]()
    var isCapsLockEnabled = false
    var isExtendedKeyboardEnabled = false
    var deleteTimer: Timer?
    var emojiKeyboardViewController: EmojiKeyboardViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        let buttonTitles = [
            ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
            ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
            ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
            ["⬆️", "z", "x", "c", "v", "b", "n", "m", "⏪"],
            ["!#1", "🙂", "space", ".", ",", "⮐"]
        ]

        // Define button size and spacing constants
        let buttonWidth: CGFloat = 30
        let buttonHeight: CGFloat = 30
        let horizontalSpacing: CGFloat = 5
        let verticalSpacing: CGFloat = 2

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(backspaceLongPressed(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.2
        view.addGestureRecognizer(longPressGestureRecognizer)

        // Loop through button titles to create buttons
        for (rowIndex, rowTitles) in buttonTitles.enumerated() {
            for (colIndex, title) in rowTitles.enumerated() {
                let button = UIButton(type: .system)
                button.setTitle(title, for: [])
                button.sizeToFit()
                button.translatesAutoresizingMaskIntoConstraints = false
                button.layer.cornerRadius = 5
                button.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
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
        let identifier = "keyboardReminder_\(type)"
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
                if !inpString.isEmpty {
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
        } else if letter == "🙂" {
            // Present the emoji keyboard
            presentEmojiKeyboard()
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
                if inpString.hasSuffix("call") {
                    scheduleNotification(type: "call")
                } else if inpString.hasSuffix("meet") {
                    scheduleNotification(type: "meet")
                } else if inpString.hasSuffix("birthday") {
                    scheduleNotification(type: "birthday")
                }
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


    func presentEmojiKeyboard() {
        emojiKeyboardViewController = EmojiKeyboardViewController()
        emojiKeyboardViewController?.emojiSelectedHandler = { [weak self] emoji in
            self?.textDocumentProxy.insertText(emoji)
        }

        if let emojiKeyboard = emojiKeyboardViewController {
            emojiKeyboard.modalPresentationStyle = .popover
            emojiKeyboard.popoverPresentationController?.sourceView = view
            emojiKeyboard.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            emojiKeyboard.popoverPresentationController?.permittedArrowDirections = []
            present(emojiKeyboard, animated: true, completion: nil)
        }
    }
}


class EmojiKeyboardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var emojiSelectedHandler: ((String) -> Void)?
    var emojiCollectionView: UICollectionView!
    var closeButton: UIButton!


    private let emojiData = [
        "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇",
        "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚",
        "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔",
        "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "🤥",
        "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮",
        "🤧", "🥵", "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "🥸", "😎",
        "💼", "📈", "📊", "📝", "💻", "📅", "📎", "📌", "📋", "✉️",
        "💡", "📚", "🗂️", "📂", "🗄️", "📑", "📊", "📉", "🗃️", "🗳️",
        "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "💔", "❣️", "💕",
        "💞", "💓", "💗", "💖", "💘", "💝", "💟", "❤️‍🔥", "❤️‍🩹",
        "🤧", "🥵", "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "🥸", "😎",
        "💩", "🤡", "👻", "💀", "👽", "👾", "🤖", "🎃", "😺", "😸",
        "😹", "😻", "😼", "😽", "🙀", "😿", "😾", "🐶", "🐱", "🐭",
        "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷",
        "🐽", "🐸", "🐙", "🐵", "🙈", "🙉", "🙊", "🐒", "🐔", "🐧",
        "🐦", "🐤", "🐣", "🐥", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗",
        "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞", "🐜", "🦗", "🕷️",
        "🕸️", "🦂", "🦟", "🦠", "🐢", "🐍", "🦎", "🐙", "🦑", "🦐",
        "🦀", "🐡", "🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐊", "🐅",
        "🐆", "🦓", "🦍", "🦧", "🦣", "🐘", "🦛", "🦏", "🐪", "🐫",
        "🦒", "🐃", "🐂", "🐄", "🐎", "🐖", "🐏", "🐑", "🦙", "🐐",
        "🦌", "🐕", "🐩", "🐈", "🐓", "🦃", "🕊️", "🐇", "🐁", "🐀",
        "🐿️", "🦔", "🐾", "🦩", "🐡", "🐲", "🦕", "🦖", "🐉", "🦧",
        "🦣", "🦕", "🦖", "🦚", "🦦", "🦤", "🦭", "🐲", "🐊", "🐍",
        "🐉", "🐋", "🐡", "🦢", "🦉", "🐬", "🐟", "🐳", "🐙", "🦑",
        "🦈", "🐚", "🦀", "🐌", "🦐", "🦑", "🐠", "🐟", "🐡", "🐚"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupEmojiCollectionView()
        setupCloseButton()
    }

    func setupEmojiCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 80, right: 16)

        emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.backgroundColor = .systemBackground
        emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        view.addSubview(emojiCollectionView)
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emojiCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupCloseButton() {
        closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeEmojiKeyboard), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func closeEmojiKeyboard() {
        dismiss(animated: true, completion: nil)
    }

    // UICollectionViewDataSource methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        cell.backgroundColor = .systemGray5
        cell.layer.cornerRadius = 8
        
        // Check if the label already exists in the cell's content view
        if let emojiLabel = cell.contentView.subviews.first as? UILabel {
            emojiLabel.text = emojiData[indexPath.row]
        } else {
            let emojiLabel = UILabel()
            emojiLabel.text = emojiData[indexPath.row]
            emojiLabel.font = UIFont.systemFont(ofSize: 24)
            emojiLabel.textAlignment = .center
            cell.contentView.addSubview(emojiLabel)
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                emojiLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                emojiLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
        }
        
        return cell
    }


    // UICollectionViewDelegate methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEmoji = emojiData[indexPath.row]
        emojiSelectedHandler?(selectedEmoji)
    }
}
