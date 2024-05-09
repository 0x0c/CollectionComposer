//
//  SwiftUIListCell.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/04/29.
//

import SwiftUI

// MARK: - SwiftUIListCell

@available(iOS 16.0, *)
open class SwiftUIListCell<View: SwiftUIListCellView>: UICollectionViewListCell {
    // MARK: Open

    open func configure(_ model: View.Model) {
        self.model = model
        contentConfiguration = if model.removeMargins {
            UIHostingConfiguration { View(model) }.margins(.all, 0)
        }
        else {
            UIHostingConfiguration { View(model) }
        }
    }

    // MARK: Internal

    private(set) var model: View.Model?
}

// MARK: - SwiftUICellViewModel

@available(iOS 16.0, *)
public protocol SwiftUICellViewModel: Hashable {
    var removeMargins: Bool { get }
}

@available(iOS 16.0, *)
public extension SwiftUICellViewModel {
    var removeMargins: Bool { false }
}

// MARK: - SwiftUIListCellView

@available(iOS 16.0, *)
public protocol SwiftUIListCellView: View {
    associatedtype Model: SwiftUICellViewModel

    init(_ model: Model)
}
