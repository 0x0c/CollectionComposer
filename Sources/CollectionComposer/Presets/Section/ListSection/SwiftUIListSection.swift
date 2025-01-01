//
//  SwiftUIListSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/04/29.
//

import SwiftUI

/// A section that displays a list of SwiftUI-based cells in a collection view layout.
///
/// `SwiftUIListSection` is an open class that conforms to `ListableSection` and `HighlightableSection`.
/// It allows for the integration of SwiftUI content within a collection view list layout, offering
/// customizable configurations, including separator handling, cell decorations, headers, and footers.
///
/// - Note: This class is available on iOS 16.0 and later.
@available(iOS 16.0, *)
open class SwiftUIListSection<View: SwiftUIListCellView>: ListableSection, HighlightableSection {
    // MARK: Lifecycle

    /// Initializes a new section with the specified identifier, items, appearance, and cell configuration.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the section.
    ///   - items: An array of models conforming to `View.Model` for configuring the cells.
    ///   - appearance: The appearance style for the list. Defaults to `.plain`.
    ///   - configuration: The configuration for cells in the section, such as insets and separator style.
    public init(
        id: String,
        items: [View.Model],
        appearance: UICollectionLayoutListConfiguration.Appearance = .plain,
        configuration: CellConfiguration = .default()
    ) {
        self.id = id
        self.items = items
        self.configuration = configuration
        prepare(appearance: appearance)
        listConfiguration.separatorConfiguration = configuration.separatorConfiguration
        listConfiguration.itemSeparatorHandler = { [weak self] indexPath, sectionSeparatorConfiguration in
            var configuration = sectionSeparatorConfiguration
            if self?.title != nil {
                configuration.topSeparatorInsets.trailing = max(16, sectionSeparatorConfiguration.topSeparatorInsets.trailing)
                configuration.bottomSeparatorInsets.trailing = max(16, sectionSeparatorConfiguration.topSeparatorInsets.trailing)
            }
            if let header = self?.header as? ExpandableHeader, indexPath.row == 0 {
                configuration.topSeparatorVisibility = header.topSeparatorVisibility
                configuration.bottomSeparatorVisibility = header.bottomSeparatorVisibility
            }
            return configuration
        }
    }

    // MARK: Open

    /// The decorations applied to the section.
    ///
    /// Decorations are additional visual elements that can be displayed with the section.
    open var decorations = [Decoration]()

    /// The title of the section used for indexing.
    open var title: String?

    /// The cell registration object used to configure cells within the section.
    ///
    /// This registration specifies how to set up a cell with a model of type `View.Model`.
    open var cellRegistration: UICollectionView.CellRegistration<
        Cell,
        View.Model
    >! = UICollectionView.CellRegistration<Cell, View.Model> { cell, _, model in
        cell.configure(model)
    }

    /// The list of items in the section.
    open var items: [View.Model]

    /// A Boolean indicating whether the section is expanded.
    open var isExpanded = true

    /// An array of items in the section, used for generating snapshots.
    open var snapshotItems: [AnyHashable] {
        return items
    }

    /// Sets the decorations for the section and returns the updated instance.
    ///
    /// - Parameter decorations: An array of decorations to apply to the section.
    /// - Returns: The updated `SwiftUIListSection` instance.
    @discardableResult
    open func decorations(_ decorations: [Decoration]) -> Self {
        self.decorations = decorations
        return self
    }

    /// Sets the index title for the section and returns the updated instance.
    ///
    /// - Parameter title: The title for indexing the section.
    /// - Returns: The updated `SwiftUIListSection` instance.
    @discardableResult
    open func indexTitle(_ title: String?) -> Self {
        self.title = title
        return self
    }

    /// Stores a header view for the section.
    ///
    /// - Parameter header: The header view to associate with the section.
    open func storeHeader(_ header: (any BoundarySupplementaryHeaderView)?) {
        self.header = header
    }

    /// Stores a footer view for the section.
    ///
    /// - Parameter footer: The footer view to associate with the section.
    open func storeFooter(_ footer: (any BoundarySupplementaryFooterView)?) {
        self.footer = footer
    }

    /// Creates and returns the layout section for this list section, based on the provided environment.
    ///
    /// This layout section arranges cells in a list layout, with configuration properties defined by `listConfiguration`.
    ///
    /// - Parameter environment: The layout environment used to create the section.
    /// - Returns: A configured `NSCollectionLayoutSection` for the list section.
    open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection.list(
            using: listConfiguration,
            layoutEnvironment: environment
        )
        section.contentInsets = configuration.contentInsets
        return section
    }

    /// Determines if an item at the specified index is highlightable.
    ///
    /// - Parameter index: The index of the item to check.
    /// - Returns: A Boolean indicating if the item is highlightable, based on the cell configuration.
    open func isHighlightable(at index: Int) -> Bool {
        return configuration.isHighlightable
    }

    /// Sets the expansion state of the section and returns the updated instance.
    ///
    /// - Parameter expand: A Boolean indicating whether the section is expanded.
    /// - Returns: The updated `SwiftUIListSection` instance.
    @discardableResult
    open func expand(_ expand: Bool) -> Self {
        isExpanded = expand
        return self
    }

    /// Updates the items in the section based on a collection difference.
    ///
    /// - Parameter difference: The difference between the current items and the new set of items.
    open func updateItems(with difference: CollectionDifference<AnyHashable>) {
        if let newItems = snapshotItems.applying(difference) {
            items = newItems.compactMap { $0 as? Item }
        }
    }

    /// Determines the target index path for moving an item within the section.
    ///
    /// This method ensures that the item remains within its original section during reordering.
    ///
    /// - Parameters:
    ///   - proposedIndexPath: The proposed index path for the item after moving.
    ///   - originalIndexPath: The original index path of the item.
    ///   - currentIndexPath: The current index path of the item.
    /// - Returns: The target index path for the item.
    open func targetIndexPathForMoveOfItemFromOriginalIndexPath(_ proposedIndexPath: IndexPath, originalIndexPath: IndexPath, currentIndexPath: IndexPath) -> IndexPath {
        if proposedIndexPath.section == originalIndexPath.section {
            return proposedIndexPath
        }
        return currentIndexPath
    }

    // MARK: Public

    /// The type of cell used in this section.
    public typealias Cell = SwiftUIListCell<View>

    /// The type of item used in this section.
    public typealias Item = View.Model

    /// The configuration for cells in the section.
    public private(set) var configuration: CellConfiguration

    /// The header view for the section, if any.
    public var header: (any BoundarySupplementaryHeaderView)?

    /// The footer view for the section, if any.
    public var footer: (any BoundarySupplementaryFooterView)?

    /// The list configuration for this section.
    public var listConfiguration: UICollectionLayoutListConfiguration!

    /// The provider for leading swipe actions in the section.
    public var leadingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider?

    /// The provider for trailing swipe actions in the section.
    public var trailingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider?

    /// The registration object for expandable headers, if applicable.
    public var expandableHeaderRegistration: UICollectionView.CellRegistration<ExpandableHeaderListCell, Void>?

    /// The unique identifier for the section.
    public let id: String

    /// Determines if the item at the specified index path can be moved.
    ///
    /// - Parameter indexPath: The index path of the item to check.
    /// - Returns: A Boolean indicating if the item can be moved.
    public func canMoveItemAt(indexPath: IndexPath) -> Bool {
        return items[indexPath.row].canMove
    }
}
