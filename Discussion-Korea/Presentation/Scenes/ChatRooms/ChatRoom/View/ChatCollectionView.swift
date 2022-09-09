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

    private var prevFrameHeight: CGFloat?

    func bottom(margin: CGFloat = 20.0) -> Bool {
        let result = self.contentOffset.y + self.frame.height + margin + 10.0 > self.contentSize.height
        return result
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

    override func layoutSubviews() {
        super.layoutSubviews()
        if let prevFrameHeight = self.prevFrameHeight,
           prevFrameHeight > self.frame.height {
            self.contentOffset.y += prevFrameHeight - self.frame.height
        }
        self.prevFrameHeight = self.frame.height
    }

}
