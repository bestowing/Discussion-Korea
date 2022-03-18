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
        self.sendButton.isEnabled = !self.messageTextView.text.isEmpty
        self.messageCollectionView.delegate = self
        self.messageCollectionView.dataSource = self
        self.messageTextView.delegate = self
        self.messageCollectionView.register(UINib(nibName: MessageCollectionViewCell.identifier, bundle: nil),
                                            forCellWithReuseIdentifier: MessageCollectionViewCell.identifier)
        self.repository.observe().sink { message in
            let item = self.messages.count
            self.messages.append(message)
            DispatchQueue.main.async { [weak self] in
                self?.messageCollectionView.reloadItems(at: [IndexPath(item: item, section: 0)])
            }
        }.store(in: &self.cancellables)
    }

    @IBAction func sendButtonDidTouch(_ sender: UIButton) {
        self.repository.send(message: messageTextView.text)
    }

}

extension ChatRoomViewController: UICollectionViewDelegate,
                                  UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCollectionViewCell.identifier, for: indexPath) as? MessageCollectionViewCell
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
