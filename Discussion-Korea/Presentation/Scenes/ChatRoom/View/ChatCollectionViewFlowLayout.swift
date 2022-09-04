//
//  ChatCollectionViewFlowLayout.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/03.
//

import UIKit

final class ChatCollectionViewFlowLayout: UICollectionViewFlowLayout {

    private var isInsertingItemsToBottom = false
    private var isInsertingItemsFirstTime = false

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        guard let collectionView = self.collectionView
        else { return }
        super.prepare(forCollectionViewUpdates: updateItems)

        let willInsertItemsToBottom = updateItems.reduce(false) {
            var result = false
            switch $1.updateAction {
            case .insert:
                if let updateItemIndexPath = $1.indexPathAfterUpdate {
                    if collectionView.numberOfItems(inSection: updateItemIndexPath.section) > updateItemIndexPath.item,
                       let _ = self.layoutAttributesForItem(at: updateItemIndexPath) {
                        result = true
                    } else if updateItemIndexPath.item == Int.max {
                        self.isInsertingItemsFirstTime = true
                    }
                }
            default:
                break
            }
            return $0 || result
        }

        if willInsertItemsToBottom {
            let collectionViewContentHeight = collectionView.contentSize.height
            let collectionViewFrameHeight = collectionView.frame.size.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)

            if collectionViewContentHeight > collectionViewFrameHeight {
                if willInsertItemsToBottom {
                    self.isInsertingItemsToBottom = true
                }
            }
        }
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        guard let collectionView = self.collectionView else { return }

        let didAnchored = { () -> Bool in
            guard let lastItemIndexPath = collectionView.indexPathsForVisibleItems.sorted(by: <).last
            else { return false }
            let items = collectionView.numberOfItems(inSection: lastItemIndexPath.section)
            return lastItemIndexPath.item + 2 >= items
        }()

        if self.isInsertingItemsFirstTime {
            self.isInsertingItemsFirstTime = false
            // TODO: 이 값이 항상 옳은지 고민해보기
            print(collectionView.contentSize.height)
            collectionView.setContentOffset(
                CGPoint(
                    x: collectionView.contentOffset.x,
                    y: collectionView.contentSize.height + super.sectionInset.bottom
                ), animated: false
            )
        } else if self.isInsertingItemsToBottom && didAnchored {
            self.isInsertingItemsToBottom = false
            // TODO: 이 값이 항상 옳은지 고민해보기
            print(collectionView.contentSize.height)
            let newContentOffset = CGPoint(
                x: collectionView.contentOffset.x,
                y: collectionView.contentSize.height - collectionView.frame.size.height + collectionView.contentInset.bottom
            )
            collectionView.setContentOffset(newContentOffset, animated: false)
        }
    }

}
