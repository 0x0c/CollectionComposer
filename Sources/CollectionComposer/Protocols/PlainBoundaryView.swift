//
//  PlainBoundaryView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/12.
//

import UIKit

// MARK: - PlainBoundaryView

/// Plain text boundary supplementary view that will appears as same appearance of UICollectionLayoutListConfiguration.
public protocol PlainBoundaryView: SupplementaryView {
    /// Text content that displays in the view
    var text: String { get }

    /// Appearance setting for the layout, defining the style of the collection view list
    var appearance: UICollectionLayoutListConfiguration.Appearance { get }
}

public extension PlainBoundaryView {
    typealias ContentView = UICollectionViewListCell

    var layoutSize: NSCollectionLayoutSize { .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(28)) }
    var absoluteOffset: CGPoint { .zero }
}

// MARK: - PlainBoundaryHeaderView

/// A supplementary view for header of sections.
public protocol PlainBoundaryHeaderView: PlainBoundaryView, ExpandableHeader {}
