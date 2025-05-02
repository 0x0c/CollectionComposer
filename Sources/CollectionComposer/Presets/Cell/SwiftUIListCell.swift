//
//  SwiftUIListCell.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/04/29.
//

import SwiftUI

// MARK: - SwiftUIListCell

/// A customizable collection view cell that hosts SwiftUI content.
///
/// `SwiftUIListCell` is a subclass of `UICollectionViewListCell` that can host a SwiftUI view,
/// allowing seamless integration of SwiftUI-based content within a collection view. It uses
/// `UIHostingConfiguration` to configure the SwiftUI content and provides options for indentation and accessories.
///
/// - Note: This class is available on iOS 16.0 and later.
@available(iOS 16.0, *)
open class SwiftUIListCell<View: SwiftUIListCellView>: UICollectionViewListCell {
    // MARK: Open

    /// Configures the cell with a model conforming to the `SwiftUICellViewEntity` protocol.
    ///
    /// This method applies the model to the SwiftUI view and sets up the cell's content configuration,
    /// adjusting margins, indentation, and accessories based on the model's properties.
    ///
    /// - Parameter model: The model to configure the cell, which provides data and layout settings.
    open func configure(_ model: View.Model) {
        self.model = model
        contentConfiguration = if model.removeMargins {
            UIHostingConfiguration { View(model) }.margins(.all, 0)
        }
        else {
            UIHostingConfiguration { View(model) }
        }
        if let width = model.indentationWidth {
            indentationWidth = width
        }
        if let level = model.indentationLevel {
            indentationLevel = level
        }
        indentsAccessories = model.indentsAccessories
        accessories = model.accessories
    }

    // MARK: Internal

    /// The model that the cell is currently configured with.
    ///
    /// This property holds the model used to set up the cell's content and layout.
    private(set) var model: View.Model?
}

// MARK: - SwiftUICellViewEntity

/// A protocol that defines the properties required for a model used in a `SwiftUIListCell`.
///
/// Conforming types provide configuration options for indentation, accessories, and movement, which are
/// used to customize the appearance and behavior of cells in a list layout.
///
/// - Note: This protocol is available on iOS 16.0 and later.
@available(iOS 16.0, *)
public protocol SwiftUICellViewEntity: Hashable, ReorderableItem {
    /// The width of the indentation for the cell, if any.
    var indentationWidth: CGFloat? { get }

    /// The level of indentation for the cell, if any.
    var indentationLevel: Int? { get }

    /// A Boolean indicating whether the cell should indent its accessories.
    var indentsAccessories: Bool { get }

    /// A Boolean indicating whether the cell's margins should be removed.
    var removeMargins: Bool { get }

    /// An array of accessories to display with the cell.
    @MainActor var accessories: [UICellAccessory] { get }

    /// A Boolean indicating whether the cell can be moved in the collection view.
    var canMove: Bool { get }
}

/// Default implementations for optional properties in `SwiftUICellViewEntity`.
@available(iOS 16.0, *)
public extension SwiftUICellViewEntity {
    var indentationWidth: CGFloat? { nil }
    var indentationLevel: Int? { nil }
    var indentsAccessories: Bool { true }
    var removeMargins: Bool { true }
    var accessories: [UICellAccessory] { [] }
    var canMove: Bool { false }
}

// MARK: - SwiftUIListCellView

/// A protocol for SwiftUI views that can be used within a `SwiftUIListCell`.
///
/// Conforming views are initialized with a model conforming to `SwiftUICellViewEntity`,
/// allowing SwiftUI content to be dynamically configured and displayed within a collection view cell.
///
/// - Note: This protocol is available on iOS 16.0 and later.
@available(iOS 16.0, *)
@MainActor
public protocol SwiftUIListCellView: View {
    /// The model type that the view uses for configuration.
    associatedtype Model: SwiftUICellViewEntity
}
