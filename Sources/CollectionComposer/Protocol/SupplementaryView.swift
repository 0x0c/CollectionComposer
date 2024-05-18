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

    var kind: String { get }
    var layoutSize: NSCollectionLayoutSize { get }
    var alignment: NSRectAlignment { get }
    var absoluteOffset: CGPoint { get }
    var registration: UICollectionView.SupplementaryRegistration<View>! { get }

    func prepare()
    func dequeueReusableSupplementary(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionReusableView
    func boundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem
}

// MARK: - SupplementaryHeaderView

public protocol SupplementaryHeaderView: SupplementaryView {}

// MARK: - SupplementaryFooterView

public protocol SupplementaryFooterView: SupplementaryView {}

public extension SupplementaryView {
    func dequeueReusableSupplementary(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionReusableView {
        collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
    }

    func boundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSize,
            elementKind: kind,
            alignment: alignment,
            absoluteOffset: absoluteOffset
        )
    }
}
