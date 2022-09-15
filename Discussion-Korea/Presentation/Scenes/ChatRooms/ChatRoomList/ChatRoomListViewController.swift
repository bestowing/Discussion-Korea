//
//  ChatRoomListViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import SnapKit
import UIKit
import RxSwift

final class ChatRoomListViewController: BaseViewController {

    // MARK: - properties

    var viewModel: ChatRoomListViewModel!

    private let titleItem: UIBarButtonItem = {
        let label = UIBarButtonItem()
        label.title = "채팅"
        label.isEnabled = false
        label.setTitleTextAttributes(
            [.font: UIFont.boldSystemFont(ofSize: 25.0),
             NSAttributedString.Key.foregroundColor: UIColor.label],
            for: .disabled
        )
        return label
    }()

    private let findButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(named: "findChat")
        button.tintColor = .label
        button.accessibilityLabel = "채팅방 탐색"
        return button
    }()

    private let addButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(named: "addChat")
        button.tintColor = .label
        button.accessibilityLabel = "채팅방 추가"
        return button
    }()

    private lazy var emptyView: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "참여한 채팅방이 없어요"
        label.font = .preferredBoldFont(forTextStyle: .body)
        label.textColor = .systemGray
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        let subLabel = UILabel()
        subLabel.text = "채팅방을 새로 만들거나 다른 채팅방에 참여해보세요"
        subLabel.font = .preferredFont(forTextStyle: .caption1)
        subLabel.textColor = .systemGray2
        subLabel.textAlignment = .center
        view.addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(5)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return view
    }()

    private lazy var chatRoomsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 75)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0

        let collectionView = UICollectionView(
            frame: .zero, collectionViewLayout: flowLayout
        )
        collectionView.backgroundColor = .clear
        collectionView.register(
            ChatRoomCell.self, forCellWithReuseIdentifier: ChatRoomCell.identifier
        )
        return collectionView
    }()

    private let backButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = ""
        button.tintColor = .label
        button.style = .plain
        return button
    }()

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.backBarButtonItem = self.backButton
        self.navigationItem.leftBarButtonItem = self.titleItem
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.rightBarButtonItems = [self.addButton, self.findButton]
        self.view.addSubview(self.chatRoomsCollectionView)
        self.chatRoomsCollectionView.addSubview(self.emptyView)
        self.emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.chatRoomsCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = ChatRoomListViewModel.Input(
            trigger: self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                .mapToVoid()
                .asDriverOnErrorJustComplete(),
            exitTrigger: Observable.empty().asDriverOnErrorJustComplete(),
            selection: self.chatRoomsCollectionView.rx.itemSelected.asDriver(),
            createChatRoomTrigger: self.addButton.rx.tap.asDriver(),
            findChatRoomTrigger: self.findButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.chatRoomItems.map { !$0.isEmpty }
            .drive(self.emptyView.rx.isHidden)
            .disposed(by: self.disposeBag)

        output.chatRoomItems.drive(self.chatRoomsCollectionView.rx.items) { collectionView, index, viewModel in
            let indexPath = IndexPath(item: index, section: 0)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatRoomCell.identifier, for: indexPath) as? ChatRoomCell
            else { return UICollectionViewCell() }
            cell.bind(viewModel)
            return cell
        }.disposed(by: self.disposeBag)

        output.events
            .drive().disposed(by: self.disposeBag)
    }

}
