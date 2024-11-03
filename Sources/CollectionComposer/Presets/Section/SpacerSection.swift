//
//  SpacerSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/09/28.
//

import SwiftUI

/// A section that acts as a spacer, adding empty vertical space within a collection view.
///
/// `SpacerSection` is a SwiftUI-based component that renders an invisible rectangle of a specified height.
/// It is useful for adding vertical spacing between sections or items in a collection view layout.
/// This class is available on iOS 16.0 and later.
///
/// ### Usage
/// ```swift
/// let spacerSection = SpacerSection(height: 20)
/// ```
///
/// - Important: This class is available only on iOS 16.0 or later.
@available(iOS 16.0, *)
open class SpacerSection: SwiftUISection {
    // MARK: Lifecycle

    /// Creates a new `SpacerSection` instance with a specified height.
    ///
    /// This initializer sets up the section with an invisible rectangle of the given height, removing
    /// default margins to ensure the space is exactly as specified.
    ///
    /// - Parameter height: The height of the spacer section, in points.
    public init(height: CGFloat) {
        self.height = height
        super.init(
            id: UUID().uuidString,
            configuration: .defaultConfiguration(removeMargins: true),
            item: SwiftUISection.ViewConfiguration(
                UIHostingConfiguration { Rectangle().foregroundStyle(.clear) }
            )
        )
    }

    // MARK: Open

    override open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(height)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = configuration.contentInsets
        return section
    }

    // MARK: Internal

    let height: CGFloat
}
