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

// MARK: - PlainHeaderView

public class PlainHeaderView: PlainBoundaryView & SupplementaryHeaderView {
    // MARK: Lifecycle

    public init(_ text: String, isExpandable: Bool = false, appearance: UICollectionLayoutListConfiguration.Appearance = .plain) {
        self.text = text
        self.isExpandable = isExpandable
        self.appearance = appearance
        prepare()
    }

    // MARK: Public

    public typealias View = UICollectionViewListCell

    public var registration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!

    public let text: String
    public let isExpandable: Bool
    public let appearance: UICollectionLayoutListConfiguration.Appearance

    public var kind: String { UICollectionView.elementKindSectionHeader }
    public var layoutSize: NSCollectionLayoutSize { .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)) }
    public var alignment: NSRectAlignment { .top }
    public var absoluteOffset: CGPoint { .zero }

    public func prepare() {
        registration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: kind
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

public class PlainFooterView: PlainBoundaryView & SupplementaryFooterView {
    // MARK: Lifecycle

    public init(_ text: String, isExpandable: Bool = false, appearance: UICollectionLayoutListConfiguration.Appearance = .plain) {
        self.text = text
        self.isExpandable = isExpandable
        self.appearance = appearance
        prepare()
    }

    // MARK: Public

    public typealias View = UICollectionViewListCell

    public var registration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!

    public let text: String
    public let isExpandable: Bool
    public let appearance: UICollectionLayoutListConfiguration.Appearance

    public var kind: String { UICollectionView.elementKindSectionFooter }
    public var layoutSize: NSCollectionLayoutSize { .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)) }
    public var alignment: NSRectAlignment { .top }
    public var absoluteOffset: CGPoint { .zero }

    public func prepare() {
        registration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: kind
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
