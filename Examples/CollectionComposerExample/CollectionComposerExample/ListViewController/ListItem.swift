//
//  ListItem.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2023/10/08.
//

import CollectionComposer
import UIKit

public struct ListItem: ListCellConfigurable {
    // MARK: Lifecycle

    public init(id: String = UUID().uuidString, image: UIImage? = nil, text: String? = nil, attributedText: NSAttributedString? = nil, secondaryText: String? = nil, secondaryAttributedText: NSAttributedString? = nil, accessories: [UICellAccessory]? = nil) {
        self.id = id
        self.image = image
        self.text = text
        self.attributedText = attributedText
        self.secondaryText = secondaryText
        self.secondaryAttributedText = secondaryAttributedText
        self.accessories = accessories
    }

    // MARK: Public

    public let id: String
    public let image: UIImage?
    public let text: String?
    public let attributedText: NSAttributedString?
    public let secondaryText: String?
    public let secondaryAttributedText: NSAttributedString?
    public let accessories: [UICellAccessory]?

    public static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
