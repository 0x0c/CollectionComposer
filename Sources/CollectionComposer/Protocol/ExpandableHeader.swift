//
//  ExpandableHeader.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/10/05.
//

import UIKit

public protocol ExpandableHeader {
    var isExpandable: Bool { get }
    var isExpanded: Bool { get }
    var accessories: [UICellAccessory] { get }
    var headerMode: UICollectionLayoutListConfiguration.HeaderMode { get }

    func headerConfiguration() -> (any UIContentConfiguration)?
    func update(using state: UICellConfigurationState) -> (any UIContentConfiguration)?
}
