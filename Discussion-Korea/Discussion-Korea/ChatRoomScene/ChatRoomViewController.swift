//
//  ChatRoomViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/17.
//

import Combine
import UIKit
import SideMenu

class ChatRoomViewController: UIViewController {
    @IBOutlet private weak var messageCollectionView: UICollectionView!
    @IBOutlet private weak var messageTextView: UITextView!
    @IBOutlet private weak var sendButton: UIButton!
    private var backgroundShadowView: UIView!

    private let repository: MessageRepository = DefaultMessageRepository(
        roomID: "1"
    )
    private var cancellables = Set<AnyCancellable>()
    private var messages: [Message] = []
    private var nicknames: [String: UserInfo] = ["bot": UserInfo(userID: "bot", nickname: "방장봇", isAdmin: false)]

    // MARK: methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.backgroundShadowView = UIView(frame: self.view.bounds)
        self.backgroundShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundShadowView.backgroundColor = .black
        self.backgroundShadowView.alpha = 0.0
        self.backgroundShadowView.isUserInteractionEnabled = false
        self.navigationController?.view.addSubview(self.backgroundShadowView)

        self.checkIfFirstEntering()
        self.observeUserInfo()
        self.observePhase()
        self.configureViews()
        self.configureTapGestureRecognizer()
        self.configureMessageCollectionView()
        self.configureNotifications()
        self.observeChatMessage()
    }

    deinit {
        self.backgroundShadowView.removeFromSuperview()
        print(#function, self)
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
        let message = Message(userID: IDManager.shared.userID(),
                              content: self.messageTextView.text,
                              date: Date(),
                              nickName: self.nicknames[IDManager.shared.userID()]?.nickname)
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
            self?.nicknames[userInfo.userID] = userInfo
        }.store(in: &self.cancellables)
    }

    private func observePhase() {
        self.repository.observePhase().sink { [unowned self] phase in
            if phase == 1 {
                // FIXME: 매번 설정해야함
                let alert = UIAlertController(title: "토론 진영 설정",
                                              message: "토론이 예정되었습니다. 참여를 원하시면 진영을 선택해주세요.",
                                              preferredStyle: UIAlertController.Style.alert)
                let agreeAction = UIAlertAction(title: "찬성", style: .default) { _ in
                    self.repository.setInfo(side: .agree)
                    self.nicknames[IDManager.shared.userID()]?.side = .agree
                }
                let disagreeAction = UIAlertAction(title: "반대", style: .destructive) { _ in
                    self.repository.setInfo(side: .disagree)
                    self.nicknames[IDManager.shared.userID()]?.side = .disagree
                }
                let judgeAction = UIAlertAction(title: "판정단", style: .default) { _ in
                    self.repository.setInfo(side: .judge)
                    self.nicknames[IDManager.shared.userID()]?.side = .judge
                }
                let observerAction = UIAlertAction(title: "구경꾼", style: .default) { _ in
                    self.repository.setInfo(side: .observer)
                    self.nicknames[IDManager.shared.userID()]?.side = .observer
                }
                alert.addAction(agreeAction)
                alert.addAction(disagreeAction)
                alert.addAction(judgeAction)
                alert.addAction(observerAction)
                self.present(alert, animated: true)
            } else if phase == 2 || phase == 5 {
                // 내가 찬성측이라면 입력 가능
                guard let side = self.nicknames[IDManager.shared.userID()]?.side,
                      side == .agree
                else {
                    self.messageTextView.text = ""
                    self.messageTextView.isEditable = false
                    self.sendButton.isEnabled = false
                    return
                }
                self.messageTextView.isEditable = true
            } else if phase == 3 || phase == 6 {
                // 내가 반대측이라면 입력 가능
                guard let side = self.nicknames[IDManager.shared.userID()]?.side,
                      side == .disagree
                else {
                    self.messageTextView.text = ""
                    self.messageTextView.isEditable = false
                    self.sendButton.isEnabled = false
                    return
                }
                self.messageTextView.isEditable = true
            } else if phase == 4 {
                // 자유토론이라 둘 다 풀어줌
                guard let side = self.nicknames[IDManager.shared.userID()]?.side,
                      (side == .disagree || side == .agree)
                else {
                    self.messageTextView.text = ""
                    self.messageTextView.isEditable = false
                    self.sendButton.isEnabled = false
                    return
                }
                self.messageTextView.isEditable = true
            } else if phase == 7 {
                // 아무도 말 못함
                self.messageTextView.text = ""
                self.messageTextView.isEditable = false
                self.sendButton.isEnabled = false
                guard let side = self.nicknames[IDManager.shared.userID()]?.side,
                      side == .judge
                else {
                    return
                }
                let alert = UIAlertController(title: "판정단 투표",
                                              message: "어느쪽이 더 잘했나요? 투표해주세요",
                                              preferredStyle: UIAlertController.Style.alert)
                let agreeAction = UIAlertAction(title: "찬성측", style: .default) { _ in
                    self.repository.vote(side: .agree)
                }
                let disagreeAction = UIAlertAction(title: "반대측", style: .destructive) { _ in
                    self.repository.vote(side: .disagree)
                }
                alert.addAction(agreeAction)
                alert.addAction(disagreeAction)
                self.present(alert, animated: true)
            } else if phase == 0 {
                self.messageTextView.isEditable = true
            }
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
            self.repository.setInfo(name: nickname)
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
        self.messageCollectionView.register(
            UINib(nibName: SerialMessageCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: SerialMessageCollectionViewCell.identifier
        )
        self.messageCollectionView.register(
            UINib(nibName: SelfMessageCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: SelfMessageCollectionViewCell.identifier
        )
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 80)
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 7
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

    private func observeChatMessage() {
        self.repository.observeChatMessage()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] message in
                var message = message
                message.nickName = self.nicknames[message.userID]?.nickname
                let item = self.messages.count
                
                if let lastMessage = self.messages.last,
                   let lastMessageDate = lastMessage.date,
                   let date = message.date {
                    let timeInterval = Int(date.timeIntervalSince(lastMessageDate))
                    if lastMessage.userID == message.userID && timeInterval < 60 {
                        self.messages[item - 1].date = nil
                        self.messageCollectionView.reloadItems(at: [IndexPath(item: item - 1, section: 0)])
                    }
                }
                self.messages.append(message)
                let indexPath = IndexPath(item: item, section: 0)
                self.messageCollectionView.insertItems(at: [indexPath])
                self.messageCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }.store(in: &self.cancellables)
    }

}

// 찬성측 말 못함 -> 찬성 고르고 나갔다 들어왔었음 -> 유저인포로 하다보니 그런듯? -> 반대측도 말 못함 지금 ㅅㅂ -> 투표도 지금 안뜬다;

extension ChatRoomViewController: UICollectionViewDelegate,
                                  UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MessageCell
        let message = self.messages[indexPath.item]
        if message.userID == IDManager.shared.userID() {
            cell = SelfMessageCollectionViewCell.dequeueReusableCell(from: collectionView, for: indexPath)
        } else {
            if indexPath.item > 0 && self.messages[indexPath.item - 1].userID == message.userID {
                cell = SerialMessageCollectionViewCell.dequeueReusableCell(from: collectionView, for: indexPath)
            } else {
                cell = MessageCollectionViewCell.dequeueReusableCell(from: collectionView, for: indexPath)
            }
        }
        cell.bind(message: message)
        return cell
    }

}

extension ChatRoomViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        self.sendButton.isEnabled = !textView.text.isEmpty
    }

}

extension ChatRoomViewController: SideMenuNavigationControllerDelegate {

    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.backgroundShadowView.alpha = 0.6
        })
    }

    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.backgroundShadowView.alpha = 0.0
        })
    }

}

final class DefaultSideMenuNavigation: SideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sideMenuDelegate = self.presentingViewController as? ChatRoomViewController
        self.presentDuration = 0.3
        self.dismissDuration = 0.3
        self.presentationStyle = .menuSlideIn
        self.menuWidth = self.view.frame.width * 0.8
    }

}
