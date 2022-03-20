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
    private var nicknames: [String: String] = [:]

    // MARK: methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkIfFirstEntering()
        self.observeUserInfo()
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
            self.view.frame.origin.y = -keyboardHeight
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        self.view.frame.origin.y = 0
    }

    @IBAction func sendButtonDidTouch(_ sender: UIButton) {
        guard !self.messageTextView.text.isEmpty
        else { return }
        let message = Message(userID: IDManager.shared.userID, content: self.messageTextView.text, date: Date())
        self.messageTextView.text = ""
        self.repository.send(number: self.messages.count + 1, message: message)
    }

    private func checkIfFirstEntering() {
        self.repository.checkIfFirstEntering().sink { [weak self] isFirstEntering in
            if isFirstEntering {
                self?.showAlertForSettingNickname()
            }
        }.store(in: &self.cancellables)
    }

    private func observeUserInfo() {
        self.repository.observeUserInfo().sink { [weak self] userInfo in
            self?.nicknames[userInfo.userID] = userInfo.nickname
        }.store(in: &self.cancellables)
    }

    private func showAlertForSettingNickname() {
        let alert = UIAlertController(title: "닉네임 설정",
                                      message: "채팅방에 처음으로 입장할때 닉네임을 설정해야 합니다.",
                                      preferredStyle: UIAlertController.Style.alert)
        let exitAction = UIAlertAction(title: "나가기", style: .cancel) {_ in
            self.navigationController?.popViewController(animated: true)
        }
        let registAction = UIAlertAction(title: "등록", style: .default) {_ in
            guard let nickname = alert.textFields?.first?.text
            else { return }
            self.repository.setNickname(by: nickname)
        }
        registAction.isEnabled = false
        alert.addTextField(configurationHandler: { textField in
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"), object: textField, queue: OperationQueue.main, using: { _ in
                registAction.isEnabled = !(textField.text?.isEmpty ?? true)
            })
            textField.placeholder = "닉네임을 입력해주세요"
        })
        alert.addAction(exitAction)
        alert.addAction(registAction)
        self.present(alert, animated: true)
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
        self.repository.observeChatMessage().sink { message in
            DispatchQueue.main.async { [weak self] in
                guard let item = self?.messages.count
                else { return }
                var message = message
                message.nickName = self?.nicknames[message.userID]
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
        // TODO: 같은 사람이 보낸 메시지는 붙여서 보이도록 Cell 개선하기
        cell.bind(message: message)
        return cell
    }

}

extension ChatRoomViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        self.sendButton.isEnabled = !textView.text.isEmpty
    }

}
