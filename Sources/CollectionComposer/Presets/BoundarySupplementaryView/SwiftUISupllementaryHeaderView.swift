//
//  SwiftUISupllementaryHeaderView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/11.
//

import SwiftUI
import UIKit

open class SwiftUISupllementaryHeaderView<T: UICollectionViewCell>: SwiftUISupllementaryView, BoundarySupplementaryHeaderView {
    // MARK: Lifecycle

    @available(iOS 16.0, *)
    public required init(
        elementKind: String,
        pinToVisibleBounds: Bool = false,
        absoluteOffset: CGPoint = .zero,
        removeMargins: Bool = true,
        extendsBoundary: Bool = true,
        @ViewBuilder content: () -> some View
    ) {
        self.elementKind = elementKind
        self.absoluteOffset = absoluteOffset
        self.pinToVisibleBounds = pinToVisibleBounds
        self.extendsBoundary = extendsBoundary
        configuration = if removeMargins {
            UIHostingConfiguration { content() }.margins(.all, 0)
        }
        else {
            UIHostingConfiguration { content() }
        }
        prepare()
    }

    public required init(
        elementKind: String,
        pinToVisibleBounds: Bool = false,
        absoluteOffset: CGPoint = .zero,
        extendsBoundary: Bool = true,
        configuration: (any UIContentConfiguration)? = nil
    ) {
        self.elementKind = elementKind
        self.absoluteOffset = absoluteOffset
        self.configuration = configuration
        self.pinToVisibleBounds = pinToVisibleBounds
        self.extendsBoundary = extendsBoundary
        prepare()
    }

    // MARK: Open

    open var registration: UICollectionView.SupplementaryRegistration<T>!
    open var configuration: UIContentConfiguration?

    open var headerMode: UICollectionLayoutListConfiguration.HeaderMode { .supplementary }

    open func prepare() {
        registration = UICollectionView.SupplementaryRegistration<T>(elementKind: elementKind) {
            supplementaryView, _, _ in
            supplementaryView.contentConfiguration = self.configuration
        }
    }

    // MARK: Public

    public typealias ContentView = T

    public let extendsBoundary: Bool

    public let pinToVisibleBounds: Bool

    public let elementKind: String
    public let absoluteOffset: CGPoint
}
