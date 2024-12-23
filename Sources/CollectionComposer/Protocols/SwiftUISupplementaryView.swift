//
//  SwiftUISupplementaryView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/20.
//

import SwiftUI
import UIKit

// MARK: - SwiftUISupplementaryView

/// `SwiftUISupllementaryView` provides interfaces to build  supplementary view with SwiftUI.
public protocol SwiftUISupplementaryView: BoundarySupplementaryView {
    @available(iOS 16.0, *)
    init(elementKind: String, pinToVisibleBounds: Bool, absoluteOffset: CGPoint, removeMargins: Bool, extendsBoundary: Bool, @ViewBuilder content: () -> some View)
    init(elementKind: String, pinToVisibleBounds: Bool, absoluteOffset: CGPoint, extendsBoundary: Bool, configuration: (any UIContentConfiguration)?)
}

public extension SwiftUISupplementaryView {
    var layoutSize: NSCollectionLayoutSize { .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)) }
}
