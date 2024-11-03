//
//  ListAppearanceHeader.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/10/05.
//

import UIKit

/// A protocol that defines a supplementary view with a configurable appearance
/// for list-based collection view layouts.
///
/// Conforming types use the `appearance` property to set the style and appearance
/// of the supplementary view in a list layout.
public protocol ListAppearanceSupplementaryView {
    
    /// The appearance configuration for the supplementary view in a list layout.
    ///
    /// This property defines the visual style of the supplementary view,
    /// using one of the predefined styles in `UICollectionLayoutListConfiguration.Appearance`.
    var appearance: UICollectionLayoutListConfiguration.Appearance { get set }
}
