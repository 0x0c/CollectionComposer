//
//  Section.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/04.
//

import UIKit

// MARK: - Decoration

/// A decoration view representation for sections.
/// This struct abstracts NSCollectionLayoutDecorationItem.
public struct Decoration {
    // MARK: Lifecycle

    public init(viewClass: AnyClass?, item: NSCollectionLayoutDecorationItem) {
        self.viewClass = viewClass
        self.item = item
    }

    // MARK: Public

    public let viewClass: AnyClass?
    public let item: NSCollectionLayoutDecorationItem
}

// MARK: - ReorderableItem

/// The items that inherit this protocol indicate each items allow to be changed its order or not.
public protocol ReorderableItem {
    /// Returns true when the item can be change the oreder in the section.
    var canMove: Bool { get }
}

// MARK: - Section

/// Section is a protocol that abstracts the NSCollectionLayoutSection.
/// Section associates the data to be displayed on the screen with the corresponding cells and their layouts.
@MainActor
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

    var contentInsetsReference: UIContentInsetsReference { get set }
    var supplementaryContentInsetsReference: UIContentInsetsReference { get set }

    /// A header supplementary view for the section.
    var header: (any BoundarySupplementaryHeaderView)? { get set }
    /// A footer supplementary view for the section.
    var footer: (any BoundarySupplementaryFooterView)? { get set }

    /// Any other supplementary views that placed at the border of the section.
    var boundarySupplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] { get }
    /// Any other decoration views that is applied into cells.
    var decorations: [Decoration] { get }

    /// A function that returns the specific layout for a cell.
    /// - Parameters:
    ///   - environment: Layout environment for current traits.
    func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection

    /// A function to configure cells.
    /// - Parameters:
    ///   - indexPath: The index path that specifies the location of the item.
    ///   - collectionView: The collection view requesting this information.
    ///   - item: An object, with a type that implements the Hashable protocol, the data source uses to uniquely identify the item for this cell.
    /// - Returns: A non-nil configured cell object. The cell provider must return a valid cell object to the collection view.
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView, item: AnyHashable) -> UICollectionViewCell

    /// A function to configure supplementary views..
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - kind: String that informs kind of the supplementary view
    ///   - indexPath:The index path that specifies the location of the view.
    /// - Returns: A non-nil configured view object.
    func supplementaryView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView?

    /// A function to configure header or footer supplementary views..
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - kind: String that informs kind of the supplementary view
    ///   - indexPath:The index path that specifies the location of the view.
    /// - Returns: A non-nil configured view object.
    func headerFooterSupplementaryView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView?

    /// A function to find an exact item of AnyHashable in provided array of items.
    /// This function is used to deque cells by dequeueConfiguredReusableCell and UICollectionView.CellRegistration.
    /// See also ``ListSection``.
    func exactItem<T>(for item: AnyHashable, in items: [T]) -> T

    /// This function is called only once when header supplementary view should be prepare to show.
    func prepareHeaderView()

    /// This function is called only once when footer supplementary view should be prepare to show.
    func prepareFooterView()

    /// Store a header view to the section.
    /// - Parameter header: A header view
    /// - Returns: The section that stores the header view.
    @discardableResult
    func header(_ header: (any BoundarySupplementaryHeaderView)?) -> Self

    /// This function is called the header view will be stored. You should store the view at the stored property manually.
    /// - Parameter header: The header view that should be stored.
    func storeHeader(_ header: (any BoundarySupplementaryHeaderView)?)

    /// Store a footer view to the section.
    @discardableResult
    func footer(_ footer: (any BoundarySupplementaryFooterView)?) -> Self

    /// This function is called the footer view will be stored. You should store the view at the stored property manually.
    /// - Parameter footer: The footer view that should be stored.
    func storeFooter(_ footer: (any BoundarySupplementaryFooterView)?)

    /// Store the decorations. You should store the items at the stored property manually.
    /// - Parameter decoration: The decorations that should be stored.
    @discardableResult
    func decorations(_ decorations: [Decoration]) -> Self

    /// Register decoration items into the section.
    /// - Parameter section: The section that should be registered the decoration items.
    func registerDecorationItems(_ section: NSCollectionLayoutSection)

    /// Register decoration views into the layout.
    /// - Parameter layout: The layout that should be registered the decoration items.
    func registerDecorationView(to layout: UICollectionViewCompositionalLayout)

    func needsToOverrideHeaderBoundarySupplementaryItem(_ layoutSection: NSCollectionLayoutSection) -> Bool
    func needsToOverrideFooterBoundarySupplementaryItem(_ layoutSection: NSCollectionLayoutSection) -> Bool

    /// Asks the delegate for the index path to use when moving an item.
    /// - Parameters:
    ///   - proposedIndexPath: The proposed index path of the item.
    ///   - originalIndexPath: The item’s original index path. This value doesn't change as the user interactively moves the item.
    ///   - currentIndexPath: The item's current index path. This value changes as the user interactively moves the item, reflecting the item's current position in the collection view.
    /// - Returns: The index path you want to use for the item. If you don't implement this method, the collection view uses the index path in the proposedIndexPath parameter.
    func targetIndexPathForMoveOfItemFromOriginalIndexPath(_ proposedIndexPath: IndexPath, originalIndexPath: IndexPath, currentIndexPath: IndexPath) -> IndexPath

    /// Update items using difference object.
    /// - Parameter difference: A collection of insertions and removals that describe the difference between two ordered collection states.
    func updateItems(with difference: CollectionDifference<AnyHashable>)
}

public extension Section {
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

    func registerDecorationItems(_ section: NSCollectionLayoutSection) {
        if decorations.isEmpty == false {
            section.decorationItems = decorations.map(\.item)
        }
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

    @discardableResult
    func header(_ header: (any BoundarySupplementaryHeaderView)?) -> Self {
        storeHeader(header)
        prepareHeaderView()
        return self
    }

    @discardableResult
    func footer(_ footer: (any BoundarySupplementaryFooterView)?) -> Self {
        storeFooter(footer)
        prepareFooterView()
        return self
    }

    func registerDecorationView(to layout: UICollectionViewCompositionalLayout) {
        for decoration in decorations {
            layout.register(decoration.viewClass, forDecorationViewOfKind: decoration.item.elementKind)
        }
    }

    func needsToOverrideHeaderBoundarySupplementaryItem(_ layoutSection: NSCollectionLayoutSection) -> Bool {
        if let header {
            let hasSectionHeader = layoutSection.boundarySupplementaryItems
                .map(\.elementKind)
                .contains(UICollectionView.elementKindSectionHeader)
            let hasUniqueSectionHeader = (header.elementKind != UICollectionView.elementKindSectionHeader)
            return hasSectionHeader && hasUniqueSectionHeader
        }
        return false
    }

    func needsToOverrideFooterBoundarySupplementaryItem(_ layoutSection: NSCollectionLayoutSection) -> Bool {
        if let footer {
            let hasSectionHeader = layoutSection.boundarySupplementaryItems
                .map(\.elementKind)
                .contains(UICollectionView.elementKindSectionFooter)
            let hasUniqueSectionHeader = (footer.elementKind != UICollectionView.elementKindSectionFooter)
            return hasSectionHeader && hasUniqueSectionHeader
        }
        return false
    }
}
