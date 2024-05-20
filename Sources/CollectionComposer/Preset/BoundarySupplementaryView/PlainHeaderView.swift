//
//  PlainHeaderView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/20.
//

import UIKit

public class PlainHeaderView: PlainBoundaryView & BoundarySupplementaryHeaderView {
    // MARK: Lifecycle

    public init(
        _ text: String,
        pinToVisibleBounds: Bool = true,
        isExpandable: Bool = false
    ) {
        self.text = text
        self.pinToVisibleBounds = pinToVisibleBounds
        self.isExpandable = isExpandable
        prepare()
    }

    // MARK: Public

    public var registration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!

    public let text: String
    public let pinToVisibleBounds: Bool
    public let isExpandable: Bool
    public var appearance: UICollectionLayoutListConfiguration.Appearance = .plain

    public var elementKind: String { UICollectionView.elementKindSectionHeader }

    public func prepare() {
        registration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: elementKind
        ) { [weak self] supplementaryView, _, _ in
            guard let self else {
                return
            }
            var configuration = Self.headerConfiguration(for: appearance)
            configuration.text = text
            if isExpandable {
                supplementaryView.accessories = [.outlineDisclosure()]
            }
            supplementaryView.contentConfiguration = configuration
        }
    }

    // MARK: Internal

    static func headerConfiguration(for appearance: UICollectionLayoutListConfiguration.Appearance) -> UIListContentConfiguration {
        switch appearance {
        case .grouped, .insetGrouped, .sidebar:
            return .groupedHeader()
        case .plain:
            return .plainHeader()
        case .sidebarPlain:
            return .sidebarHeader()
        @unknown default:
            return .plainHeader()
        }
    }
}
