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
        if let width = model.indentationWidth {
            indentationWidth = width
        }
        if let level = model.indentationLevel {
            indentationLevel = level
        }
        indentsAccessories = model.indentsAccessories
        accessories = model.accessories
    }

    // MARK: Internal

    private(set) var model: View.Model?
}

// MARK: - SwiftUICellViewModel

@available(iOS 16.0, *)
public protocol SwiftUICellViewModel: Hashable, ReorderableItem {
    var indentationWidth: CGFloat? { get }
    var indentationLevel: Int? { get }
    var indentsAccessories: Bool { get }
    var removeMargins: Bool { get }
    @MainActor var accessories: [UICellAccessory] { get }
    var canMove: Bool { get }
}

@available(iOS 16.0, *)
public extension SwiftUICellViewModel {
    var indentationWidth: CGFloat? { nil }
    var indentationLevel: Int? { nil }
    var indentsAccessories: Bool { true }
    var removeMargins: Bool { true }
    var accessories: [UICellAccessory] { [] }
    var canMove: Bool { false }
}

// MARK: - SwiftUIListCellView

@available(iOS 16.0, *)
@MainActor
public protocol SwiftUIListCellView: View {
    associatedtype Model: SwiftUICellViewModel

    init(_ model: Model)
}
