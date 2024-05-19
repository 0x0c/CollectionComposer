//
//  SwiftUISupllementaryView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/11.
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
public class SwiftUISupllementaryView: BoundarySupplementaryHeaderView {
    // MARK: Lifecycle

    public init(elementKind: String, pinToVisibleBounds: Bool = false, @ViewBuilder content: () -> some SwiftUI.View) {
        self.elementKind = elementKind
        self.pinToVisibleBounds = pinToVisibleBounds
        configuration = UIHostingConfiguration { content() }
        prepare()
    }

    public init(elementKind: String, configuration: UIContentConfiguration, pinToVisibleBounds: Bool = false) {
        self.elementKind = elementKind
        self.configuration = configuration
        self.pinToVisibleBounds = pinToVisibleBounds
        prepare()
    }

    // MARK: Public

    public typealias View = UICollectionViewListCell

    public var registration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!
    public let pinToVisibleBounds: Bool

    public let elementKind: String

    public var layoutSize: NSCollectionLayoutSize { .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)) }
    public var alignment: NSRectAlignment { .top }
    public var absoluteOffset: CGPoint { .zero }

    public func prepare() {
        registration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: elementKind) {
            supplementaryView, _, _ in
            supplementaryView.contentConfiguration = self.configuration
        }
    }

    // MARK: Internal

    static func boundarySupplementaryItems(
        alignment: NSRectAlignment,
        fractalWidth: CGFloat = 1
    ) -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(fractalWidth),
                heightDimension: .estimated(44)
            ),
            elementKind: String(describing: self),
            alignment: alignment
        )
    }

    // MARK: Private

    private let configuration: UIContentConfiguration
}
