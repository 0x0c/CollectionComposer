//
//  PlainBoundaryView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/12.
//

import UIKit

// MARK: - PlainBoundaryView

public protocol PlainBoundaryView: SupplementaryView {
    var text: String { get }
    var isExpandable: Bool { get }
    var appearance: UICollectionLayoutListConfiguration.Appearance { get }
}

public extension PlainBoundaryView {
    typealias View = UICollectionViewListCell

    var layoutSize: NSCollectionLayoutSize { .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(28)) }
    var absoluteOffset: CGPoint { .zero }
}

// MARK: - PlainHeaderView

public class PlainHeaderView: PlainBoundaryView & BoundarySupplementaryHeaderView {
    // MARK: Lifecycle

    public init(
        _ text: String,
        pinToVisibleBounds: Bool = false,
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
    public var alignment: NSRectAlignment { .top }

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

// MARK: - PlainFooterView

public class PlainFooterView: PlainBoundaryView & BoundarySupplementaryFooterView {
    // MARK: Lifecycle

    public init(
        _ text: String,
        pinToVisibleBounds: Bool = false
    ) {
        self.text = text
        self.pinToVisibleBounds = pinToVisibleBounds
        prepare()
    }

    // MARK: Public

    public var registration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!

    public let text: String
    public let pinToVisibleBounds: Bool
    public var appearance: UICollectionLayoutListConfiguration.Appearance = .plain

    public var isExpandable: Bool { false }
    public var elementKind: String { UICollectionView.elementKindSectionFooter }
    public var alignment: NSRectAlignment { .bottom }

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
