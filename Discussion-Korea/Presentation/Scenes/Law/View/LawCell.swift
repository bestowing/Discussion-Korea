//
//  LawCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import UIKit

final class LawCell: UICollectionViewCell {

    // MARK: - properties

    private let articleLabel: UILabel = {
        let label = ResizableLabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .systemGray
        return label
    }()

    private let topicLabel: UILabel = {
        let label = ResizableLabel()
        label.font = UIFont.preferredBoldFont(forTextStyle: .title3)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()

    private let gotoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .label
        return imageView
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
        self.contentView.addSubview(self.articleLabel)
        self.contentView.addSubview(self.topicLabel)
        self.contentView.addSubview(self.gotoImageView)
        self.articleLabel.snp.contentHuggingVerticalPriority = 999
        self.articleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        self.topicLabel.snp.contentHuggingVerticalPriority = 999
        self.topicLabel.snp.makeConstraints { make in
            make.top.equalTo(self.articleLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
        }
        self.gotoImageView.snp.makeConstraints { make in
            make.leading.equalTo(self.topicLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(self.topicLabel)
            make.width.height.equalTo(25)
        }
    }

    func bind(_ law: Law) {
        self.articleLabel.text = "제\(law.article)조"
        self.topicLabel.text = law.topic
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
