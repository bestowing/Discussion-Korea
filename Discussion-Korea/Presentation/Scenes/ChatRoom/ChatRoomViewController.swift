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
import RxGesture

final class ChatRoomViewController: UIViewController {

    // MARK: properties

    var viewModel: ChatRoomViewModel!

    private var itemViewModels: [ChatItemViewModel] = []

    private let time: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.tintColor = .label
        item.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0)], for: .normal
        )
        return item
    }()

    private let menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.tintColor = .label
        button.image = UIImage(systemName: "line.3.horizontal")
        button.accessibilityLabel = "메뉴"
        return button
    }()

    private let noticeView = NoticeView()
    private let liveChatView = LiveChatView()
    private let chatPreview = ChatPreview()

    private let messageCollectionView: UICollectionView = {
        let messageCollectionView = UICollectionView(
            frame: .zero, collectionViewLayout: UICollectionViewLayout.init()
        )
        messageCollectionView.backgroundColor = UIColor.systemGray6
        messageCollectionView.register(
            SelfChatCell.self, forCellWithReuseIdentifier: SelfChatCell.identifier
        )
        messageCollectionView.register(
            OtherChatCell.self, forCellWithReuseIdentifier: OtherChatCell.identifier
        )
        messageCollectionView.register(
            SerialOtherChatCell.self,
            forCellWithReuseIdentifier: SerialOtherChatCell.identifier
        )
        messageCollectionView.register(
            BotChatCell.self, forCellWithReuseIdentifier: BotChatCell.identifier
        )
        messageCollectionView.register(
            SerialBotChatCell.self, forCellWithReuseIdentifier: SerialBotChatCell.identifier
        )
        messageCollectionView.register(
            WritingChatCell.self, forCellWithReuseIdentifier: WritingChatCell.identifier
        )
        return messageCollectionView
    }()

    private let chatInputView = ChatInputView()
    private let disposeBag = DisposeBag()

    // MARK: - init/deinit

    deinit {
        print("🗑", Self.description())
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
        self.view.addSubview(self.liveChatView)
        self.view.addSubview(self.chatPreview)
        self.view.addSubview(self.noticeView)
        self.view.addSubview(self.chatInputView)
        self.navigationItem.rightBarButtonItems = [self.menuButton, self.time]
        self.noticeView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(5)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-5)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
        }
        self.liveChatView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(5)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-5)
            make.top.equalTo(self.noticeView.snp.bottom).offset(5)
        }
        self.messageCollectionView.dataSource = self
        self.messageCollectionView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            make.top.equalToSuperview()
        }
        self.chatPreview.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            make.bottom.equalTo(self.messageCollectionView.snp.bottom).offset(-10)
        }
        self.chatInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.messageCollectionView.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
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

        let bottomScrolled = self.messageCollectionView.rx.contentOffset
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map { [unowned self] offset -> Bool in
                let contentHeight = self.messageCollectionView.contentSize.height
                let frameHeight = self.messageCollectionView.frame.size.height
                let margin: CGFloat = 40
                return offset.y + margin >= (contentHeight - frameHeight)
            }
            .asDriverOnErrorJustComplete()

        let input = ChatRoomViewModel.Input(
            trigger: self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                .mapToVoid()
                .asDriverOnErrorJustComplete(),
            bottomScrolled: bottomScrolled,
            previewTouched: self.chatPreview.rx.tapGesture().when(.recognized).map { _ in }
                .asDriverOnErrorJustComplete(),
            send: self.chatInputView.rx.send.asDriver(),
            menu: self.menuButton.rx.tap.asDriver(),
            content: self.chatInputView.rx.chatContent.asDriver(),
            disappear: self.rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
                .mapToVoid()
                .asDriverOnErrorJustComplete()
        )
        let output = self.viewModel.transform(input: input)

        output.remainTime.drive(self.noticeView.rx.remainTime)
            .disposed(by: self.disposeBag)

        output.noticeContent.drive(self.noticeView.rx.content)
            .disposed(by: self.disposeBag)

        output.chatItems
            .withLatestFrom(bottomScrolled) { ($0, $1) }
            .drive { [unowned self] model, scrolled in
            let indexPath = IndexPath(item: self.itemViewModels.count, section: 0)
            self.itemViewModels.append(model)
            self.messageCollectionView.insertItems(at: [indexPath])
            if scrolled {
                self.messageCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            } else {
                self.chatPreview.bind(model)
            }
        }.disposed(by: self.disposeBag)

        output.mask.drive { [unowned self] uid in
            if let item = self.itemViewModels.firstIndex(where: { $0.chat.uid! == uid }) {
                let itemPath = IndexPath(item: item, section: 0)
                self.itemViewModels[item].chat.toxic = true
                self.messageCollectionView.reloadItems(at: [itemPath])
            }
        }.disposed(by: self.disposeBag)

        output.toBottom.drive { [unowned self] _ in
            let indexPath = IndexPath(item: self.itemViewModels.count - 1, section: 0)
            self.messageCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
        .disposed(by: self.disposeBag)

        output.isPreviewHidden.distinctUntilChanged()
            .filter { $0 }
            .drive(self.chatPreview.rx.isHidden)
            .disposed(by: self.disposeBag)

        output.realTimeChat.drive(self.liveChatView.rx.chatViewModel)
            .disposed(by: self.disposeBag)

        output.sendEnable.drive(self.chatInputView.rx.sendEnable)
            .disposed(by: self.disposeBag)

        output.editableEnable.drive(self.chatInputView.rx.isEditable)
            .disposed(by: self.disposeBag)

        output.sendEvent.drive(self.chatInputView.rx.sendEvent)
            .disposed(by: self.disposeBag)

        output.events.drive().disposed(by: self.disposeBag)
    }

}

extension ChatRoomViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = self.itemViewModels[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.identifier, for: indexPath) as? ChatCell
        else { return UICollectionViewCell() }
        cell.bind(model)
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = cell.getAccessibilityLabel(model)
        return cell
    }

}
