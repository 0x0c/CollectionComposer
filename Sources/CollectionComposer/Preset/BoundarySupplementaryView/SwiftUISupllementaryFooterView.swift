//
//  SwiftUISupllementaryFooterView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/20.
//

import SwiftUI
import UIKit

open class SwiftUISupllementaryFooterView<T: UICollectionViewCell>: SwiftUISupllementaryView, BoundarySupplementaryFooterView {
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

    open var footerMode: UICollectionLayoutListConfiguration.FooterMode { .supplementary }

    // MARK: Public

    public typealias ContentView = T

    public let extendsBoundary: Bool

    public var registration: UICollectionView.SupplementaryRegistration<T>!
    public let pinToVisibleBounds: Bool

    public let elementKind: String
    public let absoluteOffset: CGPoint

    public var configuration: UIContentConfiguration?

    public func prepare() {
        registration = UICollectionView.SupplementaryRegistration<T>(elementKind: elementKind) {
            supplementaryView, _, _ in
            supplementaryView.contentConfiguration = self.configuration
        }
    }
}
