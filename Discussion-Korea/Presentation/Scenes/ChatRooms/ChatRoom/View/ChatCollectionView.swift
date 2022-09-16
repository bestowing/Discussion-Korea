//
//  ChatCollectionView.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/09.
//

import RxSwift
import UIKit

final class ChatCollectionView: UICollectionView {

    enum Position {
        case top
        case bottom
        case none
    }

    // MARK: - properties

    private var prevFrameHeight: CGFloat?

    // MARK: - methods

    func bottom(margin: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.height + margin + 10.0 > self.contentSize.height
    }

    func position() -> Observable<Position> {
        return self.rx.contentOffset
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { [unowned self] contentOffset in
                if contentOffset.y <= 20.0 {
                    return .top
                }
                if self.bottom() {
                    return .bottom
                }
                return .none
            }
    }

    func expand() -> Bool {
        return self.contentSize.height >= self.frame.height + self.contentOffset.y
    }

    func scrollToItem(at indexPath: IndexPath) {
        self.scrollToItem(at: indexPath, at: .bottom, animated: false)
        self.contentOffset.y += (self.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset.bottom ?? 0.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard self.expand() else { return }
        if let prevFrameHeight = self.prevFrameHeight,
           prevFrameHeight > self.frame.height {
            self.contentOffset.y += prevFrameHeight - self.frame.height
        }
        self.prevFrameHeight = self.frame.height
    }

}

extension Reactive where Base: ChatCollectionView {

    var toBottom: Binder<Void> {
        return Binder(self.base) { chatCollectionView, _ in
            let section = 0
            let items = chatCollectionView.numberOfItems(inSection: section)
            let indexPath = IndexPath(item: items - 1, section: section)
            chatCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
            chatCollectionView.contentOffset.y += (chatCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset.bottom ?? 0
        }
    }

}
