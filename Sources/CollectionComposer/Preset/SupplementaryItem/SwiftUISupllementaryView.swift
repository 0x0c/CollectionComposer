//
//  SwiftUISupllementaryView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/11.
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
class SwiftUISupllementaryView: UICollectionReusableView {
    // MARK: Internal

    static let elementKind = String(describing: SwiftUISupllementaryView.self)

    static func supplementaryRegistration(_ configuration: any UIContentConfiguration) -> UICollectionView.SupplementaryRegistration<SwiftUISupllementaryView> {
        guard let registration else {
            registration = UICollectionView.SupplementaryRegistration<SwiftUISupllementaryView>(elementKind: SwiftUISupllementaryView.elementKind) {
                supplementaryView, _, _ in
                supplementaryView.configure(configuration)
            }
            return registration!
        }
        return registration
    }

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

    func configure(_ configuration: UIContentConfiguration) {
        view = configuration.makeContentView()
    }

    func configure(@ViewBuilder content: () -> some View) {
        configure(UIHostingConfiguration { content() })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let view else {
            return
        }
        if view.superview == nil {
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.topAnchor.constraint(equalTo: topAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }

    // MARK: Private

    private static var registration: UICollectionView.SupplementaryRegistration<SwiftUISupllementaryView>?

    private var view: (any UIView & UIContentView)?
}
