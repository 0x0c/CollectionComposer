//
//  SeparatorView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/04/29.
//

import UIKit

final class SeparatorView: UICollectionReusableView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray6
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    static let defaultHeight: Double = 1
    static let sectionSeparatorElementKind = String(describing: SeparatorView.self) + "-top"
    static let cellSeparatorElementKind = String(describing: SeparatorView.self) + "-bottom"

    static func sectionSeparator() -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(SeparatorView.defaultHeight)
            ),
            elementKind: SeparatorView.sectionSeparatorElementKind,
            containerAnchor: NSCollectionLayoutAnchor(edges: [.top])
        )
    }

    static func cellSeparator() -> NSCollectionLayoutSupplementaryItem {
        return NSCollectionLayoutSupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(SeparatorView.defaultHeight)
            ),
            elementKind: SeparatorView.cellSeparatorElementKind,
            containerAnchor: NSCollectionLayoutAnchor(edges: [.bottom])
        )
    }
}
