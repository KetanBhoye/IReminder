//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Daniel Saidi on 2021-02-11.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

import KeyboardKit
import SwiftUI

/**
 This keyboard demonstrates how to setup KeyboardKit and how
 to customize the standard configuration.

 To use this keyboard, you must enable it in system settings
 ("Settings/General/Keyboards"). It needs full access to get
 access to features like haptic feedback.
 */
class KeyboardViewController: KeyboardInputViewController {

    /// This function is called when the controller loads.
    ///
    /// Here, we make demo-specific service keyboard configs.
    override func viewDidLoad() {
        
        /// 💡 Setup a demo-specific action handler.
        ///
        /// The demo handler has custom code for tapping and
        /// long pressing image actions.
        services.actionHandler = DemoActionHandler(
                controller: self,
                keyboardContext: state.keyboardContext,
                keyboardBehavior: services.keyboardBehavior,
                autocompleteContext: state.autocompleteContext,
                feedbackConfiguration: state.feedbackConfiguration,
                spaceDragGestureHandler: services.spaceDragGestureHandler)
        
        /// 💡 Setup a fake autocomplete provider.
        ///
        /// This fake provider will provide fake suggestions.
        /// Try the Pro demo for real suggestions.
        services.autocompleteProvider = FakeAutocompleteProvider(
            context: state.autocompleteContext
        )
        
        /// 💡 Setup a demo-specific callout action provider.
        ///
        /// The demo provider adds "keyboard" callout action
        /// buttons to the "k" key.
        services.calloutActionProvider = StandardCalloutActionProvider(
            keyboardContext: state.keyboardContext,
            baseProvider: DemoCalloutActionProvider())
        
        /// 💡 Setup a demo-specific layout provider.
        ///
        /// The demo provider adds a "next locale" button if
        /// needed, as well as a rocket emoji button.
        services.layoutProvider = DemoLayoutProvider()
        
        /// 💡 Setup a demo-specific style provider.
        ///
        /// The demo provider styles the rocket emoji button
        /// and has some commented out code that you can try.
        services.styleProvider = DemoStyleProvider(
            keyboardContext: state.keyboardContext)
        

        /// 💡 Setup a custom keyboard locale.
        ///
        /// Without KeyboardKit Pro, changing locale will by
        /// default only affects localized texts.
        state.keyboardContext.setLocale(.english)

        /// 💡 Add more locales to the keyboard.
        ///
        /// The demo layout provider will add a "next locale"
        /// button if you have more than one locale.
        state.keyboardContext.localePresentationLocale = .current
        state.keyboardContext.locales = [] // KeyboardLocale.all.locales
        
        /// 💡 Setup a custom dictation key replacement.
        ///
        /// Since dictation is not available by default, the
        /// dictation button is removed if we don't set this.
        state.keyboardContext.keyboardDictationReplacement = .character("😀")
        
        /// 💡 Configure the space long press behavior.
        ///
        /// The locale context menu will only open up if the
        /// keyboard has multiple locales.
        state.keyboardContext.spaceLongPressBehavior = .moveInputCursor
        // state.keyboardContext.spaceLongPressBehavior = .openLocaleContextMenu
        
        /// 💡 Setup audio and haptic feedback.
        ///
        /// The code below enabled haptic feedback and plays
        /// a rocket sound when a rocket button is tapped.
        state.feedbackConfiguration.isHapticFeedbackEnabled = true
        state.feedbackConfiguration.audio.actions = [
            .init(action: .character("🙂"), feedback: .custom(id: 1303))
        ]
        
        
        // state.feedbackConfiguration.disableAudioFeedback()
        // state.feedbackConfiguration.disableHapticFeedback()
        
        /// 💡 Call super to perform the base initialization.
        super.viewDidLoad()
        
        
        
    }

    /// This function is called whenever the keyboard should
    /// be created or updated.
    ///
    /// Here, we just create a standard system keyboard like
    /// the library does it, just to show how it's done. You
    /// can customize anything you want.
    ///
    ///
    
    
    
    override func viewWillSetupKeyboard() {
        super.viewWillSetupKeyboard()

        /// 💡 Make the demo use a standard ``SystemKeyboard``.
        setup { controller in
            SystemKeyboard(
                state: controller.state,
                services: controller.services,
                buttonContent: { $0.view },
                buttonView: { $0.view.scaleEffect(0.70) },
                emojiKeyboard: { $0.view },
                toolbar: {_ in 
                    HStack {
                        
                        Button(action: {
                            self.presentEmojiKeyboard()
                        }) {
                            Text("🙂")
                        }
                        Spacer()
                    }.padding(5)
                }
            )
            // .autocorrectionDisabled()
        }
    }
}
// MARK: - EmojiKeyboard Integration

extension KeyboardViewController {
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
