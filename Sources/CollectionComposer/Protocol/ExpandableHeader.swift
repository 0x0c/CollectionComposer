//
//  ExpandableHeader.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/10/05.
//

import UIKit

// MARK: - ExpandableHeader

public protocol ExpandableHeader {
    var isExpandable: Bool { get }
    var accessories: [UICellAccessory] { get }
    var topSeparatorVisibility: UIListSeparatorConfiguration.Visibility { get }
    var bottomSeparatorVisibility: UIListSeparatorConfiguration.Visibility { get }

    func headerConfiguration(isExpanded: Bool) -> (any UIContentConfiguration)?
    func update(using state: UICellConfigurationState) -> (any UIContentConfiguration)?
}

public extension ExpandableHeader {
    var topSeparatorVisibility: UIListSeparatorConfiguration.Visibility { .automatic }
    var bottomSeparatorVisibility: UIListSeparatorConfiguration.Visibility { .automatic }
}
