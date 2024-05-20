//
//  SwiftUISupllementaryView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/20.
//

import SwiftUI
import UIKit

// MARK: - SwiftUISupllementaryView

public protocol SwiftUISupllementaryView: BoundarySupplementaryView {
    typealias ContentView = UICollectionViewListCell

    @available(iOS 16.0, *)
    init(elementKind: String, pinToVisibleBounds: Bool, absoluteOffset: CGPoint, @ViewBuilder content: () -> some View)
    init(elementKind: String, pinToVisibleBounds: Bool, absoluteOffset: CGPoint, configuration: UIContentConfiguration)
    static func boundarySupplementaryItems(alignment: NSRectAlignment, fractalWidth: CGFloat, absoluteOffset: CGPoint) -> NSCollectionLayoutBoundarySupplementaryItem
}

public extension SwiftUISupllementaryView {
    var layoutSize: NSCollectionLayoutSize { .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)) }

    static func boundarySupplementaryItems(
        alignment: NSRectAlignment,
        fractalWidth: CGFloat = 1,
        absoluteOffset: CGPoint
    ) -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(fractalWidth),
                heightDimension: .estimated(44)
            ),
            elementKind: String(describing: self),
            alignment: alignment,
            absoluteOffset: absoluteOffset
        )
    }
}
