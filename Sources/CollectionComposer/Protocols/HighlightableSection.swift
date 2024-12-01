//
//  HighlightableSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/04.
//

import Foundation

/// This section allows to higlight cells when the user interacts the cells.
public protocol HighlightableSection {
    /// This function returns which cells should be highlighted according to the index.
    func isHighlightable(at index: Int) -> Bool
}
