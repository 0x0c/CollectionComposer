//
//  HighlightableCell.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/04.
//

import UIKit

open class HighlightableCell: UICollectionViewCell {
    override open func updateConfiguration(using state: UICellConfigurationState) {
        var background = UIBackgroundConfiguration.listPlainCell().updated(for: state)
        if state.isSelected == false {
            background.backgroundColor = .clear
        }
        backgroundConfiguration = background
    }
}
