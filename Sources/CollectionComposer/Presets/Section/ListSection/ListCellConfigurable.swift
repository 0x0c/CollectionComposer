//
//  ListCellConfigurable.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/08.
//

import UIKit

// MARK: - ListCellConfigurable

/// A protocol for configuring list cells with customizable content, layout, and behavior options.
///
/// `ListCellConfigurable` provides properties to define the content, style, and layout of a cell in a list.
/// It includes options for primary and secondary text, images, accessories, and indentation, allowing
/// a flexible approach to cell configuration for list-based collection views.
///
/// - Conforms to: `Hashable`, `ReorderableItem`
public protocol ListCellConfigurable: Hashable, ReorderableItem {
    /// A unique identifier for the cell.
    ///
    /// This identifier is used to distinguish between cells in a list.
    var id: String { get }

    /// The image displayed in the cell, if any.
    var image: UIImage? { get }

    /// The primary text displayed in the cell, if any.
    var text: String? { get }

    /// The primary attributed text displayed in the cell, if any.
    ///
    /// If set, this takes precedence over `text`.
    var attributedText: NSAttributedString? { get }

    /// The secondary text displayed in the cell, if any.
    var secondaryText: String? { get }

    /// The secondary attributed text displayed in the cell, if any.
    ///
    /// If set, this takes precedence over `secondaryText`.
    var secondaryAttributedText: NSAttributedString? { get }

    /// A Boolean indicating whether the cell is highlightable.
    var isHighlightable: Bool { get }

    /// An array of accessories to display alongside the cell’s content.
    ///
    /// Accessories are additional visual elements like disclosure indicators or custom icons.
    var accessories: [UICellAccessory] { get }

    /// The width of indentation for the cell, if any.
    ///
    /// This property allows you to control how far the cell is indented in the list.
    var indentationWidth: CGFloat? { get }

    /// The level of indentation for the cell, if any.
    ///
    /// This property specifies the indentation level, typically used to nest items.
    var indentationLevel: Int? { get }

    /// A Boolean indicating whether the cell's accessories should be indented along with the content.
    var indentsAccessories: Bool { get }
}

public extension ListCellConfigurable {
    /// Determines if two `ListCellConfigurable` items are equal by comparing their hash values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side item to compare.
    ///   - rhs: The right-hand side item to compare.
    /// - Returns: `true` if the items are equal; otherwise, `false`.
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    /// Hashes the essential components of the configuration into the given hasher.
    ///
    /// This method ensures that cells are uniquely identifiable based on their content and configuration.
    ///
    /// - Parameter hasher: The hasher used to combine the values.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(image)
        hasher.combine(text)
        hasher.combine(attributedText)
        hasher.combine(secondaryText)
        hasher.combine(secondaryAttributedText)
        hasher.combine(isHighlightable)
        for accessory in accessories {
            hasher.combine(accessory.accessoryType.hashValue)
        }
        hasher.combine(canMove)
        hasher.combine(indentationWidth)
        hasher.combine(indentationLevel)
        hasher.combine(indentsAccessories)
    }

    /// A Boolean value indicating whether the cell can be moved in the list.
    ///
    /// Defaults to `false`.
    var canMove: Bool { false }

    /// The width of indentation for the cell.
    ///
    /// Defaults to `nil`, indicating no indentation.
    var indentationWidth: CGFloat? { nil }

    /// The level of indentation for the cell.
    ///
    /// Defaults to `nil`, indicating no specific indentation level.
    var indentationLevel: Int? { nil }

    /// A Boolean indicating whether the cell's accessories should be indented.
    ///
    /// Defaults to `true`.
    var indentsAccessories: Bool { true }
}
