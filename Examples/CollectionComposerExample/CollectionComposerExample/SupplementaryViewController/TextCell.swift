//
//  TextCell.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2023/10/09.
//

import UIKit

// MARK: - TextCell

class TextCell: UICollectionViewCell {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        contentView.addSubview(label)
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }

    // MARK: Internal

    static let reuseIdentifier = "text-cell-reuse-identifier"

    let label = UILabel()
}
