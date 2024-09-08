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
    init(elementKind: String, pinToVisibleBounds: Bool, absoluteOffset: CGPoint, removeMargins: Bool, extendsBoundary: Bool, @ViewBuilder content: () -> some View)
    init(elementKind: String, pinToVisibleBounds: Bool, absoluteOffset: CGPoint, extendsBoundary: Bool, configuration: (any UIContentConfiguration)?)
}

public extension SwiftUISupllementaryView {
    var layoutSize: NSCollectionLayoutSize { .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)) }
}
