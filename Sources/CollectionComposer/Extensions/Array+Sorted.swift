//
//  Array+Sorted.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/10/24.
//

import Foundation

/// An extension on collections of `IndexTitleSection` that provides a sorted array of sections by title.
///
/// This extension sorts sections alphabetically by their title property, returning
/// a new array of sections that conform to `CollectionComposer.Section`.
public extension [any IndexTitleSection] {
    /// Returns a sorted array of sections based on their titles.
    ///
    /// This method sorts the sections alphabetically using the title of each section. If
    /// either section lacks a title, it does not alter their order.
    ///
    /// - Returns: An array of `CollectionComposer.Section` instances sorted by title.
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
