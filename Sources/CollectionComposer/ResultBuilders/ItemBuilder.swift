//
//  ItemBuilder.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/09.
//

import Foundation

@resultBuilder
public enum ItemBuilder<Item> {
    public static func buildBlock(_ items: Item...) -> [Item] {
        items
    }

    public static func buildBlock(_ items: [Item]...) -> [Item] {
        items.flatMap { $0 }
    }

    public static func buildExpression(_ expression: Item) -> [Item] {
        [expression]
    }

    public static func buildOptional(_ component: [Item]?) -> [Item] {
        guard let component else {
            return []
        }
        return component
    }

    public static func buildArray(_ components: [[Item]]) -> [Item] {
        components.flatMap { $0 }
    }

    public static func buildEither(first component: Item) -> Item {
        component
    }

    public static func buildEither(second component: Item) -> Item {
        component
    }

    public static func buildEither(first component: [Item]) -> [Item] {
        component.compactMap { $0 }
    }

    public static func buildEither(second component: [Item]) -> [Item] {
        component.compactMap { $0 }
    }
}
