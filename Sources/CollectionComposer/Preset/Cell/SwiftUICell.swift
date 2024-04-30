//
//  SwiftUICell.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/04/29.
//

import SwiftUI

// MARK: - SwiftUICell

@available(iOS 16.0, *)
open class SwiftUICell<View: SwiftUICellView>: UICollectionViewCell {
    // MARK: Open

    open func configure(_ model: View.Model) {
        self.model = model
        contentConfiguration = if model.removeMergins {
            UIHostingConfiguration { View(model, isHighlighted: false) }.margins(.all, 0)
        }
        else {
            UIHostingConfiguration { View(model, isHighlighted: false) }
        }
    }

    override open func updateConfiguration(using state: UICellConfigurationState) {
        guard let model else {
            return
        }
        contentConfiguration = UIHostingConfiguration { View(model, isHighlighted: state.isHighlighted) }
    }

    // MARK: Internal

    private(set) var model: View.Model?
}

// MARK: - SwiftUICellViewModel

@available(iOS 16.0, *)
public protocol SwiftUICellViewModel: Hashable {
    var removeMergins: Bool { get }
}

@available(iOS 16.0, *)
public extension SwiftUICellViewModel {
    var removeMergins: Bool {
        return false
    }
}

// MARK: - SwiftUICellView

@available(iOS 16.0, *)
public protocol SwiftUICellView: View {
    associatedtype Model: SwiftUICellViewModel

    init(_ model: Model, isHighlighted: Bool)
}
