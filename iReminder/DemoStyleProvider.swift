//
//  DemoStyleProvider.swift
//  Keyboard
//
//  Created by Daniel Saidi on 2022-12-21.
//  Copyright © 2022-2024 Daniel Saidi. All rights reserved.
//

import KeyboardKit
import SwiftUI

/**
 This demo-specific provider inherits the standard one, then
 makes the rocket button font larger.
 
 There's a bunch of disabled code that you can enable to see
 how the style of the keyboard changes.
 */
class DemoStyleProvider: StandardKeyboardStyleProvider {
    
    override func buttonFontSize(
        for action: KeyboardAction
    ) -> CGFloat {
        let standard = super.buttonFontSize(for: action)
        return action.isRocket ? 1.8 * standard : standard
    }
    
//    override func buttonStyle(
//        for action: KeyboardAction,
//        isPressed: Bool
//    ) -> Keyboard.ButtonStyle {
//        if action.isRocket {
//            return super.buttonStyle(for: .primary(.continue), isPressed: isPressed)
//        }
//        return super.buttonStyle(for: action, isPressed: isPressed)
//    }
    
//     override func buttonImage(for action: KeyboardAction) -> Image? {
//         switch action {
//         case .primary: Image.keyboardBrightnessUp
//         default: super.buttonImage(for: action)
//         }
//     }

//     override func buttonText(for action: KeyboardAction) -> String? {
//         switch action {
//         case .primary: "⏎"
//         case .space: "SpACe"
//         default: super.buttonText(for: action)
//         }
//     }

//    override var actionCalloutStyle: Callouts.ActionCalloutStyle {
//        var style = super.actionCalloutStyle
//        style.callout.backgroundColor = .red
//        return style
//    }

//    override var inputCalloutStyle: Callouts.InputCalloutStyle {
//        var style = super.inputCalloutStyle
//        style.callout.backgroundColor = .blue
//        style.callout.textColor = .yellow
//        return style
//    }
}

private extension KeyboardAction {
    
    var isRocket: Bool {
        switch self {
        case .character(let char): char == "🙂"
        default: false
        }
    }
}

extension KeyboardViewController {
    class EmojiKeyboardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
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
            // ... (existing emoji data) ...
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

    func presentEmojiKeyboard() {
        let emojiKeyboardViewController = EmojiKeyboardViewController()
        emojiKeyboardViewController.emojiSelectedHandler = { [weak self] emoji in
            self?.textDocumentProxy.insertText(emoji)
        }

        emojiKeyboardViewController.modalPresentationStyle = .popover
        emojiKeyboardViewController.popoverPresentationController?.sourceView = view
        emojiKeyboardViewController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        emojiKeyboardViewController.popoverPresentationController?.permittedArrowDirections = []
        present(emojiKeyboardViewController, animated: true, completion: nil)
    }
}
