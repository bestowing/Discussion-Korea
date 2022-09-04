//
//  ChatRoomViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import SnapKit
import UIKit
import RxDataSources
import RxSwift
import RxKeyboard
import RxGesture

final class ChatRoomViewController: BaseViewController {

    fileprivate typealias ChatRoomDataSource = RxCollectionViewSectionedNonAnimatedDataSource<ChatSectionModel>

    // MARK: properties

    var viewModel: ChatRoomViewModel!

    private var dataSource = ChatRoomDataSource(
        configureCell: { _, collectionView, indexPath, model in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: model.identifier, for: indexPath
            ) as? ChatCell
            else { return UICollectionViewCell() }
            cell.bind(model)
            cell.isAccessibilityElement = true
            cell.accessibilityLabel = cell.getAccessibilityLabel(model)
            return cell
        }
    )

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

    private lazy var messageCollectionView: UICollectionView = {
        let flowLayout = ChatCollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        //CGSize(width: self.view.frame.width, height: 40)
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 7

        let messageCollectionView = UICollectionView(
            frame: .zero, collectionViewLayout: flowLayout
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
            loadMoreTrigger: self.messageCollectionView.position()
                .throttle(.seconds(1), scheduler: MainScheduler.instance)
                .filter { $0 == .top }
                .mapToVoid()
                .asDriverOnErrorJustComplete(),
            bottomScrolled: self.messageCollectionView.position()
                .throttle(.seconds(1), scheduler: MainScheduler.instance)
                .map { $0 == .bottom }
                .asDriverOnErrorJustComplete(),
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

        output.myRemainTime.drive(self.chatInputView.rx.remainTime)
            .disposed(by: self.disposeBag)

        output.remainTime.drive(self.noticeView.rx.remainTime)
            .disposed(by: self.disposeBag)

        output.noticeContent.drive(self.noticeView.rx.content)
            .disposed(by: self.disposeBag)

        output.chatItems
            .drive(self.messageCollectionView.rx.items(
                dataSource: self.dataSource)
            )
            .disposed(by: self.disposeBag)

//        output.mask.drive { [unowned self] uid in
//            if let item = self.itemViewModels.firstIndex(where: { $0.chat.uid! == uid }) {
//                let itemPath = IndexPath(item: item, section: 0)
//                self.itemViewModels[item].chat.toxic = true
//                self.messageCollectionView.reloadItems(at: [itemPath])
//            }
//        }.disposed(by: self.disposeBag)

//        output.toBottom.drive { [unowned self] _ in
//            let indexPath = IndexPath(item: self.itemViewModels.count - 1, section: 0)
//            self.messageCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
//        }
//        .disposed(by: self.disposeBag)

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

extension UICollectionView {

    enum Position {
        case top
        case bottom
        case none
    }

    func bottom() -> Bool {
        guard let lastItemIndexPath = self.indexPathsForVisibleItems.sorted(by: <).last
        else { return false }
        let items = self.numberOfItems(inSection: lastItemIndexPath.section)
        return lastItemIndexPath.item + 2 >= items
    }

    func position() -> Observable<Position> {
        return self.rx.contentOffset
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { [unowned self] contentOffset in
                if contentOffset.y <= 20.0 {
                    return .top
                }
                if contentOffset.y + self.frame.height + 20.0 > self.contentSize.height {
                    return .bottom
                }
                return .none
            }
    }

}

fileprivate class RxCollectionViewSectionedNonAnimatedDataSource<Section: AnimatableSectionModelType>: RxCollectionViewSectionedAnimatedDataSource<Section> {

    override func collectionView(_ collectionView: UICollectionView, observedEvent: Event<RxCollectionViewSectionedAnimatedDataSource<Section>.Element>) {
        UIView.performWithoutAnimation {
            super.collectionView(collectionView, observedEvent: observedEvent)
        }
    }

}

extension ChatItemViewModel: IdentifiableType, Equatable {

    typealias Identity = String

    var identity: String { self.chat.uid! }

    static func == (lhs: ChatItemViewModel, rhs: ChatItemViewModel) -> Bool {
        lhs.chat == rhs.chat
    }

}
