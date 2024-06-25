//
//  PlainFooterView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/20.
//

import UIKit

open class PlainFooterView: PlainBoundaryView & BoundarySupplementaryFooterView {
    // MARK: Lifecycle

    public init(
        _ text: String,
        pinToVisibleBounds: Bool = false,
        extendsBoundary: Bool = true
    ) {
        self.text = text
        self.pinToVisibleBounds = pinToVisibleBounds
        self.extendsBoundary = extendsBoundary
        prepare()
    }

    // MARK: Public

    public let extendsBoundary: Bool

    public var registration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!

    public let text: String
    public let pinToVisibleBounds: Bool
    public var appearance: UICollectionLayoutListConfiguration.Appearance = .plain

    public var isExpandable: Bool { false }
    public var elementKind: String { UICollectionView.elementKindSectionFooter }

    public func prepare() {
        registration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: elementKind
        ) { [weak self] supplementaryView, _, _ in
            guard let self else {
                return
            }
            var configuration = Self.footerConfiguration(for: appearance)
            configuration.text = text
            supplementaryView.contentConfiguration = configuration
        }
    }

    // MARK: Internal

    static func footerConfiguration(for appearance: UICollectionLayoutListConfiguration.Appearance) -> UIListContentConfiguration {
        switch appearance {
        case .grouped, .insetGrouped, .sidebar:
            return .groupedFooter()
        case .plain, .sidebarPlain:
            return .plainFooter()
        @unknown default:
            return .plainFooter()
        }
    }
}
