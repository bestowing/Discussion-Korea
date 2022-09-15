//
//  ChatRoomFindViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/15.
//

import RxSwift
import UIKit

final class ChatRoomFindViewController: BaseViewController {

    // MARK: - properties

    var viewModel: ChatRoomListViewModel!

    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.tintColor = .label
        button.accessibilityLabel = "닫기"
        return button
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

    private lazy var emptyView: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "참여할 채팅방이 없어요"
        label.font = .preferredBoldFont(forTextStyle: .body)
        label.textColor = .systemGray
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        let subLabel = UILabel()
        subLabel.text = "채팅방을 새로 만들어보세요"
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

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "채팅방 찾기"
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.leftBarButtonItem = self.exitButton
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
            exitTrigger: self.exitButton.rx.tap.asDriver(),
            selection: self.chatRoomsCollectionView.rx.itemSelected.asDriver(),
            createChatRoomTrigger: Observable.empty().asDriverOnErrorJustComplete(),
            findChatRoomTrigger: Observable.empty().asDriverOnErrorJustComplete()
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

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
