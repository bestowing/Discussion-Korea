//
//  GuideViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import RxSwift
import UIKit

final class GuideViewController: BaseViewController {

    // MARK: - properties

    var viewModel: GuideViewModel!

    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.tintColor = .label
        button.accessibilityLabel = "닫기"
        return button
    }()

    private lazy var guideCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 80)
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 20

        let collectionView = UICollectionView(
            frame: .zero, collectionViewLayout: flowLayout
        )
        collectionView.register(
            GuideCell.self, forCellWithReuseIdentifier: GuideCell.identifier
        )
        return collectionView
    }()

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "가이드"
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.leftBarButtonItem = self.exitButton
        self.view.addSubview(self.guideCollectionView)
        self.guideCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = GuideViewModel.Input(
            exitTrigger: self.exitButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.guides.drive(self.guideCollectionView.rx.items) { collectionView, index, guide in
            let indexPath = IndexPath(item: index, section: 0)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GuideCell.identifier, for: indexPath) as? GuideCell
            else { return UICollectionViewCell() }
            cell.bind(guide)
            return cell
        }
        .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
