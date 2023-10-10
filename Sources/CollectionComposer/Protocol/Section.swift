//
//  Section.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/04.
//

import UIKit

// MARK: - Section

public protocol Section {
    associatedtype Cell: UICollectionViewCell
    associatedtype Item

    var cellRegistration: UICollectionView.CellRegistration<Cell, Item>! { get }

    var identifier: String { get }
    var items: [Item] { get }
    var snapshotSection: AnyHashable { get }
    var snapshotItems: [AnyHashable] { get }
    var isExpanded: Bool { get set }
    var isExpandable: Bool { get }

    func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView, item: AnyHashable) -> UICollectionViewCell
    func supplementaryView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView?
    func exactItem<T>(for item: AnyHashable, in items: [T]) -> T
}

public extension Section {
    var snapshotSection: AnyHashable {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }

    func cell(for indexPath: IndexPath, in collectionView: UICollectionView, item: AnyHashable) -> UICollectionViewCell {
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: exactItem(for: item, in: items))
    }

    func supplementaryView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        return nil
    }

    func exactItem<T>(for item: AnyHashable, in items: [T]) -> T {
        guard let exactItem = items.first(where: {
            guard let hashable = $0 as? (any Hashable) else {
                return false
            }
            return hashable.hashValue == item.hashValue
        }) else {
            fatalError("""
            Could not find hash in items: \(item.hashValue)
            Section hash: \(snapshotSection.hashValue)
            Section items hash: \(items.compactMap { $0 as? (any Hashable) }.map(\.hashValue))
            """)
        }
        return exactItem
    }
}
