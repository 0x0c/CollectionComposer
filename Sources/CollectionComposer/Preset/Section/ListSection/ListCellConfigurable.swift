//
//  ListCellConfigurable.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/08.
//

import UIKit

// MARK: - ListCellConfigurable

public protocol ListCellConfigurable: Hashable {
    var id: String { get }
    var image: UIImage? { get }
    var text: String? { get }
    var attributedText: NSAttributedString? { get }
    var secondaryText: String? { get }
    var secondaryAttributedText: NSAttributedString? { get }

    var accessories: [UICellAccessory]? { get }
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
        accessories?.forEach {
            hasher.combine($0.accessoryType.hashValue)
        }
    }
}
