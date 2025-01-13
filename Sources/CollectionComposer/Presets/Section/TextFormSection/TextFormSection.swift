//
//  TextFormSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/01.
//

import Combine
import UIKit

// MARK: - TextFormCell

/// A protocol for configuring collection view cells that contain a `TextForm` input field.
///
/// `TextFormCell` provides properties and methods for setting up cells with a `TextForm` input field,
/// allowing configuration of text-based form elements within a collection view cell.
public protocol TextFormCell: UICollectionViewCell {
    /// The default height for the text field in the cell.
    static var defaultTextFieldHeight: CGFloat { get }

    /// The default height for the cell.
    static var defaultHeight: CGFloat { get }

    /// The input field associated with the cell.
    ///
    /// This is an instance of `TextForm.InputField` that manages text input within the form cell.
    @MainActor var inputField: InputField { get }

    /// Configures the cell with the specified form.
    ///
    /// - Parameter form: The `TextForm` object that provides data and configuration for the cell.
    @MainActor func configure(_ form: TextForm)
}

// MARK: - TextFormSection

/// A section that manages a collection of `TextFormCell` items in a collection view layout.
///
/// `TextFormSection` is an open class for organizing and displaying form input cells. It provides
/// layout configuration, decorations, and methods for managing cell registration and section updates.
open class TextFormSection<T: TextFormCell>: Section {
    // MARK: Lifecycle

    /// Initializes a new form section with the specified identifier, cell type, and items.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the section.
    ///   - type: The type of cell (class-based or nib-based) to use in the section.
    ///   - items: An array of `TextForm` items representing each form element in the section.
    public init(id: String, type: CellType = .class, items: [TextForm]) {
        self.id = id
        self.type = type
        self.items = items
        self.items.linkForms()
        cellRegistration = makeCellRegistration()
    }

    /// Convenience initializer that uses a result builder to create `TextForm` items.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the section.
    ///   - type: The type of cell (class-based or nib-based) to use in the section.
    ///   - items: A closure that returns an array of `TextForm` items for the section.
    public convenience init(id: String, type: CellType = .class, @ItemBuilder<TextForm> _ items: () -> [TextForm]) {
        self.init(id: id, type: type, items: items())
    }

    // MARK: Open

    /// The list of decorations for the section.
    ///
    /// Decorations are additional views or elements displayed alongside the cells.
    open var decorations = [Decoration]()

    /// The cell registration object used to configure cells in this section.
    ///
    /// This registration specifies how to set up a cell with a `TextForm`.
    open var cellRegistration: UICollectionView.CellRegistration<T, TextForm>!

    /// A Boolean indicating whether the section is expanded.
    open var isExpanded = false

    /// A Boolean indicating whether the section is expandable.
    open var isExpandable = false

    /// The list of form items in the section.
    open private(set) var items = [TextForm]()

    /// The unique identifier for the section.
    open var id: String

    /// An array of items in the section used for generating snapshots.
    open var snapshotItems: [AnyHashable] {
        return items
    }

    /// Creates and returns the cell registration for this section based on the cell type.
    ///
    /// - Returns: A `UICollectionView.CellRegistration` for configuring cells in the section.
    open func makeCellRegistration() -> UICollectionView.CellRegistration<T, TextForm> {
        switch type {
        case let .nib(nib):
            return UICollectionView.CellRegistration<T, TextForm>(cellNib: nib) { cell, _, model in
                cell.configure(model)
            }
        case .class:
            return UICollectionView.CellRegistration<T, TextForm> { cell, _, model in
                cell.configure(model)
            }
        }
    }

    /// Sets the decorations for the section and returns the updated instance.
    ///
    /// - Parameter decorations: An array of decorations to apply to the section.
    /// - Returns: The updated `TextFormSection` instance.
    @discardableResult
    open func decorations(_ decorations: [Decoration]) -> Self {
        self.decorations = decorations
        return self
    }

    /// Creates and returns the layout section for this form section, based on the provided environment.
    ///
    /// This layout section arranges cells with estimated height dimensions and custom insets.
    ///
    /// - Parameter environment: The layout environment to use for creating the section.
    /// - Returns: A configured `NSCollectionLayoutSection` for the form section.
    open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(T.defaultHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(T.defaultHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.boundarySupplementaryItems = boundarySupplementaryItems
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

    /// An enum representing the type of cell to use in the form section.
    public enum CellType {
        /// A cell type based on a nib file.
        case nib(UINib)

        /// A class-based cell type.
        case `class`
    }

    /// The header view for the section, if any.
    public var header: (any BoundarySupplementaryHeaderView)?

    /// The footer view for the section, if any.
    public var footer: (any BoundarySupplementaryFooterView)?

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

    // MARK: Private

    /// The type of cell (class-based or nib-based) used in the section.
    private let type: CellType
}

extension [TextForm] {
    /// Links the `TextForm` instances in the array, establishing a next and previous form relationship.
    ///
    /// This method iterates over the forms and sets up `next` and `previous` relationships
    /// to allow navigating between forms.
    func linkForms() {
        var iterator = makeIterator()
        var current: TextForm? = iterator.next()
        var previous: TextForm?
        while let next = iterator.next() {
            current?.previous = previous
            current?.next = next
            previous = current
            current = next
        }
    }
}
