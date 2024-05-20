//
//  SwiftUISupllementaryHeaderView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/11.
//

import SwiftUI
import UIKit

public class SwiftUISupllementaryHeaderView: SwiftUISupllementaryView & BoundarySupplementaryHeaderView {
    // MARK: Lifecycle

    @available(iOS 16.0, *)
    public required init(elementKind: String, pinToVisibleBounds: Bool = false, absoluteOffset: CGPoint = .zero, @ViewBuilder content: () -> some View) {
        self.elementKind = elementKind
        self.absoluteOffset = absoluteOffset
        self.pinToVisibleBounds = pinToVisibleBounds
        configuration = UIHostingConfiguration { content() }
        prepare()
    }

    public required init(elementKind: String, pinToVisibleBounds: Bool = false, absoluteOffset: CGPoint = .zero, configuration: UIContentConfiguration) {
        self.elementKind = elementKind
        self.absoluteOffset = absoluteOffset
        self.configuration = configuration
        self.pinToVisibleBounds = pinToVisibleBounds
        prepare()
    }

    // MARK: Public

    public var registration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!
    public let pinToVisibleBounds: Bool

    public let elementKind: String
    public let absoluteOffset: CGPoint

    public func prepare() {
        registration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: elementKind) {
            supplementaryView, _, _ in
            supplementaryView.contentConfiguration = self.configuration
        }
    }

    // MARK: Private

    private let configuration: UIContentConfiguration
}
