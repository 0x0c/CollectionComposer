//
//  ExpandableHeader.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/10/05.
//

import UIKit

// MARK: - ExpandableHeader

/// This protocol adds expandability features to cells that can be used as section headers
public protocol ExpandableHeader {
    /// Indicates whether the section can be expanded
    var isExpandable: Bool { get }

    /// List of accessories (additional UI elements) to be displayed in the cell
    var accessories: [UICellAccessory] { get }

    /// Visibility setting for the top separator of the cell
    var topSeparatorVisibility: UIListSeparatorConfiguration.Visibility { get }

    /// Visibility setting for the bottom separator of the cell
    var bottomSeparatorVisibility: UIListSeparatorConfiguration.Visibility { get }

    /// Configures the header appearance
    /// - Parameter isExpanded: - a flag indicating whether the header is expanded
    /// - Returns: A UIContentConfiguration object for the header
    func headerConfiguration(isExpanded: Bool) -> (any UIContentConfiguration)?

    /// Updates the cell based on its configuration state (e.g., selected, highlighted)
    /// - Parameter state: - the configuration state of the cell
    /// - Returns: An updated UIContentConfiguration object
    func update(using state: UICellConfigurationState) -> (any UIContentConfiguration)?
}

/// Provide default implementations for the ExpandableHeader protocol
public extension ExpandableHeader {
    /// Default setting for the top separator visibility (automatic configuration)
    var topSeparatorVisibility: UIListSeparatorConfiguration.Visibility { .automatic }

    /// Default setting for the bottom separator visibility (automatic configuration)
    var bottomSeparatorVisibility: UIListSeparatorConfiguration.Visibility { .automatic }
}
