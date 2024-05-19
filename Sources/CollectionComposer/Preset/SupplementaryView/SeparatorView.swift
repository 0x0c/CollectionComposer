//
//  SeparatorView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/04/29.
//

import UIKit

public final class SeparatorView: UICollectionReusableView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .separator
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    static let defaultHeight: Double = 1
    static let sectionSeparatorElementKind = String(describing: SeparatorView.self) + "-top"
    static let cellSeparatorElementKind = String(describing: SeparatorView.self) + "-bottom"

    static func sectionSeparator(
        edges: NSDirectionalRectEdge,
        fractalWidth: CGFloat = 1
    ) -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(fractalWidth),
                heightDimension: .absolute(SeparatorView.defaultHeight)
            ),
            elementKind: SeparatorView.sectionSeparatorElementKind,
            containerAnchor: NSCollectionLayoutAnchor(edges: edges)
        )
    }

    static func cellSeparator(
        edges: NSDirectionalRectEdge,
        fractalWidth: CGFloat = 1
    ) -> NSCollectionLayoutSupplementaryItem {
        return NSCollectionLayoutSupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(fractalWidth),
                heightDimension: .absolute(SeparatorView.defaultHeight)
            ),
            elementKind: SeparatorView.cellSeparatorElementKind,
            containerAnchor: NSCollectionLayoutAnchor(edges: edges)
        )
    }
}
