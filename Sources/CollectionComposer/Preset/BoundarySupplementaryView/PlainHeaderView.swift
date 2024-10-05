//
//  PlainHeaderView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/20.
//

import UIKit

open class PlainHeaderView: PlainBoundaryHeaderView, BoundarySupplementaryHeaderView, ListAppearanceSupplementaryView {
    // MARK: Lifecycle

    public init(
        _ text: String,
        pinToVisibleBounds: Bool = true,
        isExpandable: Bool = false,
        extendsBoundary: Bool = true
    ) {
        self.text = text
        self.pinToVisibleBounds = pinToVisibleBounds
        self.isExpandable = isExpandable
        self.extendsBoundary = extendsBoundary
        prepare()
    }

    // MARK: Open

    open var registration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!
    open var isExpanded: Bool = false
    open var appearance: UICollectionLayoutListConfiguration.Appearance = .plain

    open var headerMode: UICollectionLayoutListConfiguration.HeaderMode { isExpandable ? .firstItemInSection : .none }

    open var elementKind: String { UICollectionView.elementKindSectionHeader }

    open var accessories: [UICellAccessory] { [.outlineDisclosure()] }

    open func prepare() {
        registration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: elementKind
        ) { [weak self] supplementaryView, _, _ in
            guard let self else {
                return
            }
            var configuration = headerConfiguration() as! UIListContentConfiguration
            configuration.text = text
            if isExpandable {
                supplementaryView.accessories = [.outlineDisclosure()]
            }
            supplementaryView.contentConfiguration = configuration
        }
    }

    // MARK: Public

    public let extendsBoundary: Bool
    public let text: String
    public let pinToVisibleBounds: Bool
    public let isExpandable: Bool

    public func headerConfiguration() -> (any UIContentConfiguration)? {
        var configuration: UIListContentConfiguration = {
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
        }()
        configuration.text = text
        return configuration
    }

    public func update(using state: UICellConfigurationState) -> (any UIContentConfiguration)? {
        return headerConfiguration()
    }
}
