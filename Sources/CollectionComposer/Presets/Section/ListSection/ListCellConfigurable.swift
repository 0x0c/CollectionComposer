//
//  ListCellConfigurable.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/08.
//

import UIKit

// MARK: - ListCellConfigurable

public protocol ListCellConfigurable: Hashable, ReorderableItem {
    var id: String { get }
    var image: UIImage? { get }
    var text: String? { get }
    var attributedText: NSAttributedString? { get }
    var secondaryText: String? { get }
    var secondaryAttributedText: NSAttributedString? { get }
    var isHighlightable: Bool { get }

    var accessories: [UICellAccessory] { get }

    var indentationWidth: CGFloat? { get }
    var indentationLevel: Int? { get }
    var indentsAccessories: Bool { get }
}

public extension ListCellConfigurable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

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

    var canMove: Bool { false }
    var indentationWidth: CGFloat? { nil }
    var indentationLevel: Int? { nil }
    var indentsAccessories: Bool { true }
}
