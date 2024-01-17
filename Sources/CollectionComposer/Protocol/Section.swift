//
//  Section.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/04.
//

import UIKit

// MARK: - Section

/// Section is a protocol that abstracts the NSCollectionLayoutSection.
/// Section associates the data to be displayed on the screen with the corresponding cells and their layouts.
public protocol Section {
    associatedtype Cell: UICollectionViewCell
    associatedtype Item

    var cellRegistration: UICollectionView.CellRegistration<Cell, Item>! { get }

    /// An identifier for the section. Each section to be displayed on the screen must be assigned a unique identifier.
    var identifier: String { get }
    /// Items for associating cells.
    var items: [Item] { get }
    var snapshotSection: AnyHashable { get }
    var snapshotItems: [AnyHashable] { get }
    /// Indicates the section expands cells or not.
    var isExpanded: Bool { get set }
    /// Indicates the section allows to expand cells.
    var isExpandable: Bool { get }

    /// A function that returns the specific layout for a cell.
    /// - Parameters:
    ///   - environment: Layout environment for current traits.
    func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    /// A function to configure cells.
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView, item: AnyHashable) -> UICollectionViewCell
    /// A function to configure supplementary views..
    func supplementaryView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView?
    /// A function to find an exact item of AnyHashable in provided array of items.
    /// This function is used to deque cells by dequeueConfiguredReusableCell and UICollectionView.CellRegistration.
    /// See also ``ListSection``.
    func exactItem<T>(for item: AnyHashable, in items: [T]) -> T
    /// Indicates the section allows to highlight cells.
    func isHighlightable(for index: Int) -> Bool
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
