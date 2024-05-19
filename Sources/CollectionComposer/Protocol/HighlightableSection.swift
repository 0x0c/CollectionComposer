//
//  HighlightableSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/04.
//

import Foundation

public protocol HighlightableSection {
    /// Indicates the section allows to highlight cells.
    func isHighlightable(at index: Int) -> Bool
}
