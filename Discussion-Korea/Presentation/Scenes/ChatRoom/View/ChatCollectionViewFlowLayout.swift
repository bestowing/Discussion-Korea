//
//  ChatCollectionViewFlowLayout.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/03.
//

import UIKit

final class ChatCollectionViewFlowLayout: UICollectionViewFlowLayout {

    private var topMostVisibleItem = Int.max
    private var bottomMostVisibleItem = -Int.max
    private var visibleAttributes: [UICollectionViewLayoutAttributes]?

    private var offsetItems: [IndexPath]?

    private var isInsertingItemsToTop = false
    private var isInsertingItemsToBottom = false
    private var isInsertingItemsFirstTime = false

    override func layoutAttributesForItem(
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView,
              let layoutAttributes = super.layoutAttributesForItem(
                at: indexPath
              )?.copy() as? UICollectionViewLayoutAttributes
        else { return nil }
        layoutAttributes.frame.origin.x = sectionInset.left
        layoutAttributes.frame.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
        return layoutAttributes
    }

    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributesObjects = super.layoutAttributesForElements(in: rect)?
            .map { $0.copy() } as? [UICollectionViewLayoutAttributes]
        layoutAttributesObjects?.forEach { layoutAttributes in
            if layoutAttributes.representedElementCategory == .cell,
               let newFrame = layoutAttributesForItem(at: layoutAttributes.indexPath)?.frame {
                layoutAttributes.frame = newFrame
            }
        }
        self.visibleAttributes = layoutAttributesObjects
        return self.visibleAttributes
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

        var willInsertItemsToTop = false
        var willInsertItemsToBottom = false
        var offsetItems: [IndexPath] = []
        for updateItem in updateItems {
            guard updateItem.updateAction == .insert,
                  let updateItemIndexPath = updateItem.indexPathAfterUpdate
            else { continue }
            if self.bottomMostVisibleItem <= updateItemIndexPath.item {
                if collectionView.numberOfItems(inSection: updateItemIndexPath.section) > updateItemIndexPath.item {
                    willInsertItemsToBottom = true
                } else if updateItemIndexPath.item == Int.max {
                    self.isInsertingItemsFirstTime = true
                }
            } else {
                offsetItems.append(updateItemIndexPath)
                willInsertItemsToTop = true
            }
        }
        self.offsetItems = offsetItems.isEmpty ? nil : offsetItems
        if willInsertItemsToTop {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.isInsertingItemsToTop = true
        } else if willInsertItemsToBottom && updateItems.count == 1 {
            self.isInsertingItemsToBottom = true
        }
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        guard let collectionView = self.collectionView else { return }
        if self.isInsertingItemsToBottom && collectionView.bottom() {
            self.isInsertingItemsToBottom = false
            self.scrollToLastItem(collectionView)
        } else if isInsertingItemsToTop {
            self.isInsertingItemsToTop = false
            guard let offsetItems = offsetItems
            else { return }
            let offset: CGFloat = offsetItems.reduce(0.0) { [unowned self] in
                guard let newAttributes = self.layoutAttributesForItem(at: $1)
                else { return $0 }
                return $0 + newAttributes.size.height + self.minimumLineSpacing
            }
            let newContentOffset = CGPoint(
                x: collectionView.contentOffset.x,
                y: collectionView.contentOffset.y + offset
            )
            self.offsetItems = nil
            collectionView.contentOffset = newContentOffset
            CATransaction.commit()
        } else if self.isInsertingItemsFirstTime {
            self.isInsertingItemsFirstTime = false
            self.scrollToLastItem(collectionView)
        }
    }

    private func scrollToLastItem(_ collectionView: UICollectionView) {
        collectionView.contentOffset = CGPoint(
            x: collectionView.contentOffset.x,
            y: collectionView.contentSize.height - collectionView.frame.size.height
        )
    }
}
