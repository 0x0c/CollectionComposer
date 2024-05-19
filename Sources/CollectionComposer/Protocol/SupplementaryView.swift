//
//  SupplementaryView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/12.
//

import UIKit

// MARK: - SupplementaryView

public protocol SupplementaryView {
    associatedtype View: UICollectionReusableView

    var elementKind: String { get }
    var layoutSize: NSCollectionLayoutSize { get }
    var alignment: NSRectAlignment { get }
    var absoluteOffset: CGPoint { get }
    var pinToVisibleBounds: Bool { get }

    func prepare()
    func dequeueReusableSupplementary(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionReusableView
}

// MARK: - BoundarySupplementaryView

public protocol BoundarySupplementaryView: SupplementaryView {
    var registration: UICollectionView.SupplementaryRegistration<View>! { get }

    func boundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem
}

// MARK: - BoundarySupplementaryHeaderView

public protocol BoundarySupplementaryHeaderView: BoundarySupplementaryView {}

// MARK: - BoundarySupplementaryFooterView

public protocol BoundarySupplementaryFooterView: BoundarySupplementaryView {}

public extension BoundarySupplementaryView {
    func dequeueReusableSupplementary(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionReusableView {
        collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
    }

    func boundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let item = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSize,
            elementKind: elementKind,
            alignment: alignment,
            absoluteOffset: absoluteOffset
        )
        item.pinToVisibleBounds = pinToVisibleBounds
        return item
    }
}
