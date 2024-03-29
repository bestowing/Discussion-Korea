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

final class ChatRoomViewController: BaseViewController {

    // MARK: - properties

    var viewModel: ChatRoomViewModel!

    private var itemViewModels: [ChatItemViewModel] = []
    private var cachedHeights: [String: CGFloat] = [:]

    private var didSetupViewConstraints = false
    private var isExpanded = false

    private let tapProfileSubject = PublishSubject<ChatItemViewModel>()

    private let menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.tintColor = .label
        button.image = UIImage(systemName: "line.horizontal.3")
        button.accessibilityLabel = "메뉴"
        return button
    }()

    private let noticeView = NoticeView()
    private let liveChatView = LiveChatView()
    private let chatPreview = ChatPreview()

    private lazy var messageCollectionView: ChatCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0

        let messageCollectionView = ChatCollectionView(
            frame: .zero, collectionViewLayout: flowLayout
        )
        messageCollectionView.dataSource = self
        messageCollectionView.delegate = self
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

    // MARK: - methods

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
        self.navigationItem.rightBarButtonItem = self.menuButton
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
        self.messageCollectionView.snp.contentHuggingVerticalPriority = 1
        self.messageCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
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

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.messageCollectionView.addGestureRecognizer(tap)

        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [unowned self] keyboardVisibleHeight in
                guard self.didSetupViewConstraints else { return }
                self.chatInputView.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().inset(
                        keyboardVisibleHeight == 0 ? self.view.safeAreaInsets.bottom : 0
                    )
                }
                self.view.setNeedsLayout()
                UIView.animate(withDuration: 0) {
                    self.view.bounds.origin.y = keyboardVisibleHeight
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let bottomScrolled = self.messageCollectionView.position()
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { [unowned self] position -> Bool in
                if position == .bottom {
                    return true
                }
                let prev = self.isExpanded
                self.isExpanded = self.messageCollectionView.expand()
                return (!self.isExpanded) || prev != self.isExpanded
            }
            .distinctUntilChanged()
            .asDriverOnErrorJustComplete()

        let input = ChatRoomViewModel.Input(
            trigger: self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                .mapToVoid()
                .asDriverOnErrorJustComplete(),
            loadMoreTrigger: self.messageCollectionView.position()
                .throttle(.seconds(1), scheduler: MainScheduler.instance)
                .filter { $0 == .top }
                .mapToVoid()
                .asDriverOnErrorJustComplete(),
            bottomScrolled: bottomScrolled,
            previewTouched: self.chatPreview.rx.tapGesture()
                .when(.recognized).mapToVoid()
                .asDriverOnErrorJustComplete(),
            profileSelection: self.tapProfileSubject.asDriverOnErrorJustComplete(),
            send: self.chatInputView.rx.send.asDriver(),
            menu: self.menuButton.rx.tap.asDriver(),
            content: self.chatInputView.rx.chatContent.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.myRemainTime.drive(self.chatInputView.rx.remainTime)
            .disposed(by: self.disposeBag)

        output.remainTime.drive(self.noticeView.rx.remainTime)
            .disposed(by: self.disposeBag)

        output.noticeContent.drive(self.noticeView.rx.content)
            .disposed(by: self.disposeBag)

        output.chatItems.drive { [unowned self] viewModels in
            self.itemViewModels = viewModels
            let indexPaths = (0..<viewModels.count).map {
                return IndexPath(item: $0, section: 0)
            }
            self.messageCollectionView.insertItems(at: indexPaths)
            if let last = indexPaths.last {
                self.messageCollectionView.scrollToItem(at: last, at: .bottom, animated: false)
            }
        }
        .disposed(by: self.disposeBag)

        output.moreLoaded.drive { [unowned self] viewModels in
            self.itemViewModels = viewModels + self.itemViewModels
            let indexPaths = (0..<viewModels.count).map {
                return IndexPath(item: $0, section: 0)
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.messageCollectionView.insertItems(at: indexPaths)
            let indexPath = IndexPath(item: viewModels.count, section: 0)
            self.messageCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            CATransaction.commit()
        }
        .disposed(by: self.disposeBag)

        output.newChatItem.withLatestFrom(bottomScrolled) { ($0, $1) }
            .drive { [unowned self] viewModel, bottomScrolled in
            let indexPath = IndexPath(item: self.itemViewModels.count, section: 0)
            var differences = [indexPath]
            if var last = self.itemViewModels.last,
               last.chat.userID == viewModel.chat.userID,
               let lastDate = last.chat.date,
               let currentDate = viewModel.chat.date,
               Int(currentDate.timeIntervalSince(lastDate)) < 60 {
                last.chat.date = nil
                self.itemViewModels[self.itemViewModels.count - 1] = last
                differences.append(
                    IndexPath(item: self.itemViewModels.count - 1, section: 0)
                )
            }
            self.itemViewModels.append(viewModel)
            UIView.performWithoutAnimation {
                self.messageCollectionView.insertItems(at: differences)
                if bottomScrolled || self.messageCollectionView.bottom() {
                    self.messageCollectionView.scrollToItem(
                        at: indexPath, at: .bottom, animated: false
                    )
                }
            }
        }
        .disposed(by: self.disposeBag)

        output.maskedChatUID.drive { [unowned self] uid in
            self.cachedHeights[uid] = nil
            if let item = self.itemViewModels.firstIndex(where: { $0.chat.uid! == uid }) {
                self.itemViewModels[item].chat.toxic = true
                self.messageCollectionView.reloadItems(
                    at: [IndexPath(item: item, section: 0)]
                )
            }
        }
        .disposed(by: self.disposeBag)

        output.toBottom.drive(self.messageCollectionView.rx.toBottom)
            .disposed(by: self.disposeBag)

        output.preview
            .drive(self.chatPreview.rx.latest)
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

    override func updateViewConstraints() {
        super.updateViewConstraints()
        guard !self.didSetupViewConstraints else { return }
        self.didSetupViewConstraints = true

        self.chatInputView.snp.contentHuggingVerticalPriority = 999
        self.chatInputView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.messageCollectionView.snp.bottom)
            make.bottom.equalToSuperview().offset(-self.view.safeAreaInsets.bottom)
        }
    }

}

extension ChatRoomViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemViewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = self.itemViewModels[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.cellIdentifier, for: indexPath) as? ChatCell
        else { return UICollectionViewCell() }
        cell.bind(model)
        cell.action = Action(
            action: { [unowned self] in
                self.tapProfileSubject.onNext(model)
            }
        )
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = cell.getAccessibilityLabel(model)
        return cell
    }

}

extension ChatRoomViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let model = self.itemViewModels[indexPath.item]
        if let cache = self.cachedHeights[model.chat.uid!] {
            return CGSize(width: width, height: cache)
        }
        let size = self.getSize(width: width, viewModel: model)
        self.cachedHeights[model.chat.uid!] = size.height
        return size
    }

    private func getSize(width: CGFloat, viewModel: ChatItemViewModel) -> CGSize {
        switch viewModel.cellIdentifier {
        case DefaultChatItemViewModelFactory.CellIdentifier.selfChat.rawValue:
            return SelfChatCell.sizeFittingWith(cellWidth: width, viewModel: viewModel)
        case DefaultChatItemViewModelFactory.CellIdentifier.serialOtherChat.rawValue:
            return SerialOtherChatCell.sizeFittingWith(cellWidth: width, viewModel: viewModel)
        case DefaultChatItemViewModelFactory.CellIdentifier.otherChat.rawValue:
            return OtherChatCell.sizeFittingWith(cellWidth: width, viewModel: viewModel)
        case DefaultChatItemViewModelFactory.CellIdentifier.botChat.rawValue:
            return BotChatCell.sizeFittingWith(cellWidth: width, viewModel: viewModel)
        default:
            return SerialBotChatCell.sizeFittingWith(cellWidth: width, viewModel: viewModel)
        }
    }

}
