//
//  SeparatorView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/04/29.
//

import UIKit

/// A reusable view that serves as a separator within a collection view.
///
/// `SeparatorView` is a simple, reusable view intended to act as a visual divider between sections
/// or items in a collection view. It inherits from `UICollectionReusableView`, making it ideal for use
/// in supplementary views where separators are needed.
///
/// - Note: Customize the appearance of `SeparatorView` by setting its background color or by adding
/// other visual properties to match your app's design.
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
