//
//  SupplementaryView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/12.
//

import UIKit

// MARK: - SupplementaryView

@MainActor
public protocol SupplementaryView {
    associatedtype ContentView: UICollectionReusableView

    var elementKind: String { get }
    var layoutSize: NSCollectionLayoutSize { get }
    var alignment: NSRectAlignment { get }
    var absoluteOffset: CGPoint { get }
    var pinToVisibleBounds: Bool { get }
    var extendsBoundary: Bool { get }

    func prepare()
    func dequeueReusableSupplementary(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionReusableView
}

// MARK: - BoundarySupplementaryView

@MainActor
public protocol BoundarySupplementaryView: SupplementaryView {
    var registration: UICollectionView.SupplementaryRegistration<ContentView>! { get }

    func boundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem
}

// MARK: - BoundarySupplementaryHeaderView

@MainActor
public protocol BoundarySupplementaryHeaderView: BoundarySupplementaryView {
    var headerMode: UICollectionLayoutListConfiguration.HeaderMode { get }
}

public extension BoundarySupplementaryHeaderView {
    var alignment: NSRectAlignment { .top }
}

// MARK: - BoundarySupplementaryFooterView

@MainActor
public protocol BoundarySupplementaryFooterView: BoundarySupplementaryView {
    var footerMode: UICollectionLayoutListConfiguration.FooterMode { get }
}

public extension BoundarySupplementaryFooterView {
    var alignment: NSRectAlignment { .bottom }
}

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
        item.extendsBoundary = extendsBoundary
        return item
    }
}
