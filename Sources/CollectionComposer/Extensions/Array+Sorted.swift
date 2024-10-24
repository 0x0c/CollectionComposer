//
//  Array+Sorted.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/10/24.
//

import Foundation

public extension [any IndexTitleSection] {
    func indexSorted() -> [any CollectionComposer.Section] {
        return sorted { first, second in
            guard let firstTitle = first.title,
                  let secondTitle = second.title else {
                return false
            }
            return firstTitle < secondTitle
        }
    }
}
