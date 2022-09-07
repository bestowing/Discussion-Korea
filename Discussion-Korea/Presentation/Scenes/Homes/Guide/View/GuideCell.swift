//
//  GuideCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import UIKit

final class GuideCell: UICollectionViewCell {

    // MARK: - properties

    private let titleLabel: UILabel = {
        let label = ResizableLabel()
        label.font = UIFont.preferredBoldFont(forTextStyle: .title3)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()

    private let contentLabel: UILabel = {
        let label = ResizableLabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()

    // MARK: - init/deinit

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layoutViews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutViews()
    }

    // MARK: - methods

    private func layoutViews() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.contentLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(0)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(0)
        }
    }

    func bind(_ guide: Guide) {
        self.titleLabel.text = guide.title
        self.contentLabel.text = guide.content
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        self.layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }

}

