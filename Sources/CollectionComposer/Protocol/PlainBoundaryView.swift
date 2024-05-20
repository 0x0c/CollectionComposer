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
    typealias ContentView = UICollectionViewListCell

    var layoutSize: NSCollectionLayoutSize { .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(28)) }
    var absoluteOffset: CGPoint { .zero }
}

// MARK: - PlainHeaderView

// MARK: - PlainFooterView
