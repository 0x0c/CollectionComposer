//
//  BasicButtonCell.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/04.
//

import UIKit

/// A basic collection view cell that contains a button, providing a customizable button cell for list or grid layouts.
///
/// `BasicButtonCell` is a subclass of `UICollectionViewCell` that conforms to the `ButtonCell` protocol,
/// designed for iOS 16.0 and later. It includes a `UIButton` that fills the cell's content view, allowing
/// developers to configure the button as needed.
@available(iOS 16.0, *)
open class BasicButtonCell: UICollectionViewCell, ButtonCell {
    // MARK: Lifecycle

    /// Initializes a new button cell with the specified frame.
    ///
    /// This initializer sets up the `button` as a subview of the cell's `contentView`
    /// and configures its constraints to make it fill the entire content view.
    ///
    /// - Parameter frame: The frame rectangle for the cell, measured in points.
    override public init(frame: CGRect) {
        super.init(frame: frame)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    /// Unavailable initializer.
    ///
    /// This initializer is unavailable and will trigger a fatal error if called.
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    // MARK: Public

    /// The button displayed within the cell.
    ///
    /// This button fills the entire cell and can be configured as needed for various interactions.
    public let button: UIButton = {
        let button = UIButton(frame: .zero)
        return button
    }()
}
