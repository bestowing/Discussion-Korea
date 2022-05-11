//
//  ChatRoomViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import SnapKit
import UIKit
import RxSwift
import RxKeyboard
import RxDataSources

final class ChatRoomViewController: UIViewController {

    // MARK: - properties

    var viewModel: ChatRoomViewModel!

    private let menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "menu"
        return button
    }()

    private let messageCollectionView: UICollectionView = {
        let messageCollectionView = UICollectionView(
            frame: .zero, collectionViewLayout: UICollectionViewLayout.init()
        )
        messageCollectionView.backgroundColor = UIColor.systemGray6
        messageCollectionView.register(SelfChatCell.self, forCellWithReuseIdentifier: SelfChatCell.identifier)
        messageCollectionView.register(OtherChatCell.self, forCellWithReuseIdentifier: OtherChatCell.identifier)
        messageCollectionView.register(SerialOtherChatCell.self, forCellWithReuseIdentifier: SerialOtherChatCell.identifier)
        return messageCollectionView
    }()

    private let messageTextView: UITextView = {
        let messageTextView = UITextView()
        messageTextView.font = UIFont.systemFont(ofSize: 14.0)
        messageTextView.isScrollEnabled = false
        return messageTextView
    }()

    private let sendButton: UIButton = {
        let sendButton = UIButton()
        sendButton.setTitle("보내기", for: .normal)
        sendButton.setTitleColor(UIColor.label, for: .normal)
        sendButton.setTitleColor(UIColor.red, for: .disabled)
        sendButton.isEnabled = false
        return sendButton
    }()

    private let disposeBag = DisposeBag()

    // MARK: - init/deinit

    deinit {
        print(#function, self)
    }

    // MARK: - methods

    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.view.addSubview(self.messageCollectionView)
        self.view.addSubview(self.messageTextView)
        self.view.addSubview(self.sendButton)
        self.navigationItem.rightBarButtonItem = self.menuButton
        self.messageCollectionView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.messageTextView.snp.top).offset(-10)
        }
        self.messageTextView.snp.contentCompressionResistanceVerticalPriority = 751
        self.messageTextView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(10)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        self.sendButton.snp.makeConstraints { make in
            make.leading.equalTo(self.messageTextView.snp.trailing).offset(10)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            make.centerY.equalTo(self.messageTextView)
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 80)
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 7
        self.messageCollectionView.collectionViewLayout = flowLayout

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)

        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [unowned self] keyboardVisibleHeight in
                self.view.frame.origin.y = -keyboardVisibleHeight
            })
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = ChatRoomViewModel.Input(
            trigger: self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                .mapToVoid()
                .asDriverOnErrorJustComplete(),
            send: self.sendButton.rx.tap.asDriver(),
            menu: self.menuButton.rx.tap.asDriver(),
            content: self.messageTextView.rx.text.orEmpty.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.chatItems.drive(self.messageCollectionView.rx.items) { collectionView, index, model in
            let indexPath = IndexPath(item: index, section: 0)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.identifier, for: indexPath) as? ChatCell
            else { return UICollectionViewCell() }
            cell.bind(model)
            return cell
        }.disposed(by: self.disposeBag)

        output.userInfos.drive().disposed(by: self.disposeBag)

        output.sendEnable.drive(self.sendButton.rx.isEnabled)
            .disposed(by: self.disposeBag)

        output.sideMenuEvent.drive().disposed(by: self.disposeBag)

        output.sendEvent
            .drive(onNext: { [unowned self] in
                self.messageTextView.text = ""
            })
            .disposed(by: self.disposeBag)

        output.enterEvent
            .drive()
            .disposed(by: self.disposeBag)
    }

}
