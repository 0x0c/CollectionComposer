//
//  PlainFooterView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/20.
//

import UIKit

open class PlainFooterView: PlainBoundaryView, BoundarySupplementaryFooterView, ListAppearanceSupplementaryView {
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

    // MARK: Open

    open var registration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!

    open var appearance: UICollectionLayoutListConfiguration.Appearance = .plain

    open var isExpandable: Bool { false }
    open var elementKind: String { UICollectionView.elementKindSectionFooter }

    open var footerMode: UICollectionLayoutListConfiguration.FooterMode { .none }

    open func prepare() {
        registration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: elementKind
        ) { [weak self] supplementaryView, _, _ in
            guard let self else {
                return
            }
            var configuration = footerConfiguration()
            configuration.text = text
            supplementaryView.contentConfiguration = configuration
        }
    }

    // MARK: Public

    public let extendsBoundary: Bool

    public let text: String
    public let pinToVisibleBounds: Bool

    // MARK: Internal

    func footerConfiguration() -> UIListContentConfiguration {
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
