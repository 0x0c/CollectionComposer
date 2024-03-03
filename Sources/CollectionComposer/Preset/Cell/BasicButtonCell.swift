//
//  BasicButtonCell.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/04.
//

import UIKit

@available(iOS 16.0, *)
open class BasicButtonCell: UICollectionViewCell, ButtonCell {
    // MARK: Lifecycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }

    // MARK: Public

    public let button: UIButton = {
        let button = UIButton(frame: .zero)
        return button
    }()
}
