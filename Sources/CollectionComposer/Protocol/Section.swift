//
//  Section.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/04.
//

import UIKit

// MARK: - HeaderMode

public enum HeaderMode {
    case firstItemInSection
    case supplementary
}

// MARK: - Section

/// Section is a protocol that abstracts the NSCollectionLayoutSection.
/// Section associates the data to be displayed on the screen with the corresponding cells and their layouts.
public protocol Section {
    associatedtype Cell: UICollectionViewCell
    associatedtype Item

    var cellRegistration: UICollectionView.CellRegistration<Cell, Item>! { get }

    /// An identifier for the section. Each section to be displayed on the screen must be assigned a unique identifier.
    var id: String { get }
    /// Items for associating cells.
    var items: [Item] { get }
    var snapshotSection: AnyHashable { get }
    var snapshotItems: [AnyHashable] { get }
    /// Indicates the section expands cells or not.
    var isExpanded: Bool { get set }
    /// Indicates the section allows to expand cells.
    var isExpandable: Bool { get }

    var headerMode: HeaderMode { get }
    var header: (any BoundarySupplementaryHeaderView)? { get set }
    var footer: (any BoundarySupplementaryFooterView)? { get set }

    var boundarySupplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] { get }

    /// A function that returns the specific layout for a cell.
    /// - Parameters:
    ///   - environment: Layout environment for current traits.
    func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    /// A function to configure cells.
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView, item: AnyHashable) -> UICollectionViewCell
    /// A function to configure supplementary views..
    func supplementaryView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView?
    /// A function to configure header or footer supplementary views..
    func headerFooterSupplementaryView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView?
    /// A function to find an exact item of AnyHashable in provided array of items.
    /// This function is used to deque cells by dequeueConfiguredReusableCell and UICollectionView.CellRegistration.
    /// See also ``ListSection``.
    func exactItem<T>(for item: AnyHashable, in items: [T]) -> T

    func prepareHeaderView()
    func prepareFooterView()
    func storeHeader(_ header: any BoundarySupplementaryHeaderView)
    func storeFooter(_ footer: any BoundarySupplementaryFooterView)
    func header(_ header: any BoundarySupplementaryHeaderView) -> Self
    func footer(_ footer: any BoundarySupplementaryFooterView) -> Self

    func shouldOverrideBoundarySupplementaryItem(_ layoutSection: NSCollectionLayoutSection) -> Bool
}

public extension Section {
    var headerMode: HeaderMode { .supplementary }

    var boundarySupplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] {
        var items = [NSCollectionLayoutBoundarySupplementaryItem]()
        if let header {
            items.append(header.boundarySupplementaryItem())
        }
        if let footer {
            items.append(footer.boundarySupplementaryItem())
        }
        return items
    }

    var snapshotSection: AnyHashable {
        var hasher = Hasher()
        hasher.combine(id)
        return hasher.finalize()
    }

    func cell(for indexPath: IndexPath, in collectionView: UICollectionView, item: AnyHashable) -> UICollectionViewCell {
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: exactItem(for: item, in: items))
    }

    func supplementaryView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        return headerFooterSupplementaryView(collectionView, kind: kind, indexPath: indexPath)
    }

    func headerFooterSupplementaryView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        if let header, header.elementKind == kind {
            return header.dequeueReusableSupplementary(collectionView: collectionView, for: indexPath)
        }
        if let footer, footer.elementKind == kind {
            return footer.dequeueReusableSupplementary(collectionView: collectionView, for: indexPath)
        }
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

    func prepareHeaderView() {}
    func prepareFooterView() {}

    func header(_ header: any BoundarySupplementaryHeaderView) -> Self {
        storeHeader(header)
        prepareHeaderView()
        return self
    }

    func footer(_ footer: any BoundarySupplementaryFooterView) -> Self {
        storeFooter(footer)
        prepareFooterView()
        return self
    }

    func shouldOverrideBoundarySupplementaryItem(_ layoutSection: NSCollectionLayoutSection) -> Bool {
        if let header {
            return headerMode == .supplementary
        }
        if let footer {
            return true
        }
        return false
    }
}
