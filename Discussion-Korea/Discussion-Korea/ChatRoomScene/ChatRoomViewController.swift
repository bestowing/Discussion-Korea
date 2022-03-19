//
//  ChatRoomViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/17.
//

import Combine
import UIKit

class ChatRoomViewController: UIViewController {
    @IBOutlet private weak var messageCollectionView: UICollectionView!
    @IBOutlet private weak var messageTextView: UITextView!
    @IBOutlet private weak var sendButton: UIButton!

    private let repository: MessageRepository = DefaultMessageRepository()
    private var cancellables = Set<AnyCancellable>()
    private var messages: [Message] = []

    // MARK: methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        self.configureTapGestureRecognizer()
        self.configureMessageCollectionView()
        self.configureNotifications()
        self.configureCancellable()
    }

    @objc func viewDidTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self.view.window?.frame.origin.y = -keyboardHeight
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        self.view.window?.frame.origin.y = 0
    }

    @IBAction func sendButtonDidTouch(_ sender: UIButton) {
        guard !self.messageTextView.text.isEmpty
        else { return }
        let message = Message(userID: IDManager.shared.userID, content: self.messageTextView.text, date: Date())
        self.messageTextView.text = ""
        self.repository.send(number: self.messages.count + 1, message: message)
    }

    private func configureViews() {
        self.sendButton.isEnabled = !self.messageTextView.text.isEmpty
        self.messageTextView.delegate = self
    }

    private func configureTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    private func configureMessageCollectionView() {
        self.messageCollectionView.delegate = self
        self.messageCollectionView.dataSource = self
        self.messageCollectionView.register(
            UINib(nibName: MessageCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: MessageCollectionViewCell.identifier
        )
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 80)
        self.messageCollectionView.collectionViewLayout = flowLayout
    }

    private func configureNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func configureCancellable() {
        self.repository.observe().sink { message in
            DispatchQueue.main.async { [weak self] in
                guard let item = self?.messages.count
                else { return }
                self?.messages.append(message)
                let indexPath = IndexPath(item: item, section: 0)
                self?.messageCollectionView.insertItems(at: [indexPath])
                self?.messageCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
        }.store(in: &self.cancellables)
    }

}

extension ChatRoomViewController: UICollectionViewDelegate,
                                  UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MessageCollectionViewCell.identifier,
            for: indexPath
        ) as? MessageCollectionViewCell
        else { return MessageCollectionViewCell() }
        let message = self.messages[indexPath.item]
        cell.bind(message: message)
        return cell
    }

}

extension ChatRoomViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        self.sendButton.isEnabled = !textView.text.isEmpty
    }

}
