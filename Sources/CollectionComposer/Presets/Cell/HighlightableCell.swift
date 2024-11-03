//
//  HighlightableCell.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/04.
//

import UIKit

/// A collection view cell that customizes its background appearance based on its selection state.
///
/// `HighlightableCell` is a subclass of `UICollectionViewCell` that adjusts its background color
/// when the cell is not selected, making it suitable for highlighting purposes in a list or grid layout.
open class HighlightableCell: UICollectionViewCell {
    /// Updates the cell’s configuration using the specified state.
    ///
    /// This method customizes the background appearance of the cell based on its selection state.
    /// When the cell is not selected, the background color is set to clear. The background configuration
    /// uses `UIBackgroundConfiguration.listPlainCell()` to provide a plain background style.
    ///
    /// - Parameter state: The current state of the cell, provided by `UICellConfigurationState`.
    override open func updateConfiguration(using state: UICellConfigurationState) {
        var background = UIBackgroundConfiguration.listPlainCell().updated(for: state)
        if state.isSelected == false {
            background.backgroundColor = .clear
        }
        backgroundConfiguration = background
    }
}
