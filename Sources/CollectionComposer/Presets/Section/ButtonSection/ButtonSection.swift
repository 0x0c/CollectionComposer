//
//  ButtonSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/01/18.
//

import UIKit

// MARK: - ButtonCell

/// A protocol for collection view cells containing a button.
///
/// `ButtonCell` provides a simple interface for cells that contain a button as their primary
/// interactive element, allowing cells to be easily configured and reused in sections with button-based layouts.
///
/// - Note: This protocol is available on iOS 16.0 and later.
@available(iOS 16.0, *)
public protocol ButtonCell: UICollectionViewCell {
    /// The button displayed within the cell.
    ///
    /// This button can be configured with various properties and actions to provide
    /// interactive functionality in the cell.
    var button: UIButton { get }
}

// MARK: - ButtonSection

/// A collection view section that displays button-based cells with a customizable configuration and action handler.
///
/// `ButtonSection` is an open class that manages a collection of button cells. It supports
/// setting decorations, layout configurations, and actions for button interactions.
///
/// - Note: This class is available on iOS 16.0 and later.
@available(iOS 16.0, *)
open class ButtonSection<T: ButtonCell>: Section {
    // MARK: Lifecycle

    /// Initializes a new button section with the specified identifier, button configuration, and action handler.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the section.
    ///   - configuration: The configuration for the button, including style and layout properties.
    ///   - handler: The action handler for button interactions within the section.
    public init(id: String, configuration: ButtonConfiguration, handler: @escaping ButtonSectionContext.Handler) {
        self.id = id
        context = ButtonSectionContext(id: id, configuration: configuration, handler: handler)
        items = [context]
    }

    // MARK: Open

    /// The list of decorations for the section.
    ///
    /// Decorations are additional views or elements that can be displayed alongside the cells.
    open var decorations = [Decoration]()

    /// The cell registration object used to configure cells in this section.
    ///
    /// This registration specifies how to set up a cell with the provided `ButtonSectionContext`.
    open var cellRegistration: UICollectionView.CellRegistration<
        T, ButtonSectionContext
    >! = UICollectionView.CellRegistration<T, ButtonSectionContext> { cell, _, model in
        cell.button.configuration = model.configuration.buttonConfiguration
        cell.button.addAction(model.action, for: .touchUpInside)
    }

    /// The unique identifier for the section.
    open var id: String

    /// The items in the section, which are instances of `ButtonSectionContext`.
    open var items: [ButtonSectionContext]

    /// A Boolean indicating whether the section is expanded.
    open var isExpanded = false

    /// A Boolean indicating whether the section is expandable.
    open var isExpandable = false

    /// An array of items in the section used for generating snapshots.
    ///
    /// This array contains hashable representations of each item’s unique identifier.
    open var snapshotItems: [AnyHashable] {
        return items.map { AnyHashable($0.id) }
    }

    /// Sets the decorations for the section and returns the updated instance.
    ///
    /// - Parameter decorations: An array of decorations to apply to the section.
    /// - Returns: The updated `ButtonSection` instance.
    @discardableResult
    open func decorations(_ decorations: [Decoration]) -> Self {
        self.decorations = decorations
        return self
    }

    /// Creates and returns the layout section for this button section, based on the provided environment.
    ///
    /// This layout section arranges cells horizontally, with size and insets derived from the button configuration.
    ///
    /// - Parameter environment: The layout environment to use for creating the section.
    /// - Returns: A configured `NSCollectionLayoutSection` for the button section.
    open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(context.configuration.buttonHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = context.configuration.contentInsets
        return section
    }

    /// Determines if an item at the specified index is highlightable.
    ///
    /// This method returns `false` by default, meaning items in this section are not highlightable.
    ///
    /// - Parameter index: The index of the item to check.
    /// - Returns: A Boolean indicating if the item is highlightable.
    open func isHighlightable(for index: Int) -> Bool {
        return false
    }

    /// Updates the items in the section based on a collection difference.
    ///
    /// This method can be overridden to handle item updates, though it does nothing by default.
    ///
    /// - Parameter difference: The difference between the current items and the new set of items.
    open func updateItems(with difference: CollectionDifference<AnyHashable>) {}

    // MARK: Public

    /// The header view for the section, if any.
    public var header: (any BoundarySupplementaryHeaderView)?

    /// The footer view for the section, if any.
    public var footer: (any BoundarySupplementaryFooterView)?

    /// Stores a header view for the section.
    ///
    /// - Parameter header: The header view to associate with the section.
    public func storeHeader(_ header: (any BoundarySupplementaryHeaderView)?) {
        self.header = header
    }

    /// Stores a footer view for the section.
    ///
    /// - Parameter footer: The footer view to associate with the section.
    public func storeFooter(_ footer: (any BoundarySupplementaryFooterView)?) {
        self.footer = footer
    }

    /// Determines the target index path for moving an item within the section.
    ///
    /// This method ensures the item remains within its original section during reordering.
    ///
    /// - Parameters:
    ///   - proposedIndexPath: The proposed index path for the item after moving.
    ///   - originalIndexPath: The original index path of the item.
    ///   - currentIndexPath: The current index path of the item.
    /// - Returns: The target index path for the item.
    public func targetIndexPathForMoveOfItemFromOriginalIndexPath(_ proposedIndexPath: IndexPath, originalIndexPath: IndexPath, currentIndexPath: IndexPath) -> IndexPath {
        if proposedIndexPath.section == originalIndexPath.section {
            return proposedIndexPath
        }
        return currentIndexPath
    }

    // MARK: Internal

    /// The context for the section, which includes button configuration and an action handler.
    let context: ButtonSectionContext
}
