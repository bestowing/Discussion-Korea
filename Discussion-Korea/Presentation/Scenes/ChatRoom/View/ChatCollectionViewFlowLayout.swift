//
//  ChatCollectionViewFlowLayout.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/03.
//

import UIKit

final class ChatCollectionViewFlowLayout: UICollectionViewFlowLayout {

    private var bottomMostVisibleItem = -Int.max
    private var offset: CGFloat = 0.0
    private var visibleAttributes: [UICollectionViewLayoutAttributes]?

    private var isInsertingItemsToBottom = false

    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        self.visibleAttributes = super.layoutAttributesForElements(in: rect)
        self.offset = 0.0
        return visibleAttributes
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        guard let collectionView = self.collectionView,
              let visibleAttributes = self.visibleAttributes
        else { return }
        self.bottomMostVisibleItem = -Int.max
        let container = CGRect(
            x: collectionView.contentOffset.x,
            y: collectionView.contentOffset.y,
            width: collectionView.frame.size.width,
            height: (
                collectionView.frame.size.height - (
                    collectionView.contentInset.top + collectionView.contentInset.bottom
                )
            )
        )
        visibleAttributes.forEach { attributes in
            if attributes.frame.intersects(container) {
                let item = attributes.indexPath.item
                if item > self.bottomMostVisibleItem { self.bottomMostVisibleItem = item }
            }
        }
        super.prepare(forCollectionViewUpdates: updateItems)
        let willInsertItemsToBottom = updateItems.reduce(false) {
            var result = false
            switch $1.updateAction {
            case .insert:
                if let updateItemIndexPath = $1.indexPathAfterUpdate,
                   self.bottomMostVisibleItem <= updateItemIndexPath.item,
                   collectionView.numberOfItems(inSection: updateItemIndexPath.section) > updateItemIndexPath.item,
                   let newAttributes = self.layoutAttributesForItem(at: updateItemIndexPath) {
                    self.offset += (newAttributes.size.height + self.minimumLineSpacing)
                    result = true
                }
            default:
                break
            }
            return $0 || result
        }

        if willInsertItemsToBottom {
            let collectionViewContentHeight = collectionView.contentSize.height
            let collectionViewFrameHeight = collectionView.frame.size.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)

            if collectionViewContentHeight + offset > collectionViewFrameHeight {
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

        if self.isInsertingItemsToBottom && didAnchored {
            self.isInsertingItemsToBottom = false
            // TODO: 이 값이 항상 옳은지 고민해보기
            let newContentOffset = CGPoint(
                x: collectionView.contentOffset.x,
                y: collectionView.contentSize.height + self.offset - collectionView.frame.size.height + collectionView.contentInset.bottom
            )
            self.offset = 0.0
            // Set new content offset with animation
            collectionView.setContentOffset(newContentOffset, animated: false)
        }
    }

}
