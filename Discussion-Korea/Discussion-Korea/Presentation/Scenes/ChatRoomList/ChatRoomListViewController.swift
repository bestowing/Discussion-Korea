//
//  ChatRoomListViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import SnapKit
import UIKit
import RxSwift

final class ChatRoomListViewController: UIViewController {

    // MARK: properties

    var viewModel: ChatRoomListViewModel!

    private let titleItem: UIBarButtonItem = {
        let label = UIBarButtonItem()
        label.title = "채팅"
        label.isEnabled = false
        label.setTitleTextAttributes(
            [.font: UIFont.boldSystemFont(ofSize: 25.0), NSAttributedString.Key.foregroundColor: UIColor.label],
            for: .disabled
        )
        return label
    }()

    private let addButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "plus.message")
        button.tintColor = .label
        button.accessibilityLabel = "채팅방 추가"
        return button
    }()

    private let chatRoomsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero ,collectionViewLayout: UICollectionViewLayout()
        )
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
        self.navigationItem.backBarButtonItem = self.backButton
        self.navigationItem.leftBarButtonItem = self.titleItem
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.rightBarButtonItem = self.addButton
        self.view.addSubview(self.chatRoomsCollectionView)
        self.chatRoomsCollectionView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: self.view.frame.width, height: 75)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0

        self.chatRoomsCollectionView.collectionViewLayout = flowLayout
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = ChatRoomListViewModel.Input(
            trigger: self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                .mapToVoid()
                .asDriverOnErrorJustComplete(),
            selection: self.chatRoomsCollectionView.rx.itemSelected.asDriver(),
            createChatRoomTrigger: self.addButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

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
