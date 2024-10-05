//
//  ExpandableHeader.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/10/05.
//

import UIKit

public protocol ExpandableHeader {
    var isExpandable: Bool { get }
    var accessories: [UICellAccessory] { get }

    func headerConfiguration() -> (any UIContentConfiguration)?
    func update(using state: UICellConfigurationState) -> (any UIContentConfiguration)?
}
