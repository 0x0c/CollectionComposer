//
//  SpacerSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/09/28.
//

import SwiftUI

@available(iOS 16.0, *)
open class SpacerSection: SwiftUISection {
    let height: CGFloat

    open override func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
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
}
