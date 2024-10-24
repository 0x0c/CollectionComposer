//
//  SectionBuilder.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/09.
//

import Foundation

// MARK: - SectionBuilder

@resultBuilder
public enum SectionBuilder {
    public static func buildBlock(_ sections: any Section...) -> [any Section] {
        sections
    }

    public static func buildBlock(_ section: [any Section]...) -> [any Section] {
        section.flatMap { $0 }
    }

    public static func buildExpression(_ expression: any Section) -> [any Section] {
        [expression]
    }

    public static func buildOptional(_ component: [any Section]?) -> [any Section] {
        guard let component else {
            return []
        }
        return component
    }

    public static func buildArray(_ components: [[any Section]]) -> [any Section] {
        components.flatMap { $0 }
    }

    public static func buildEither(first component: any Section) -> any Section {
        component
    }

    public static func buildEither(second component: any Section) -> any Section {
        component
    }

    public static func buildEither(first component: [any Section]) -> [any Section] {
        component.compactMap { $0 }
    }

    public static func buildEither(second component: [any Section]) -> [any Section] {
        component.compactMap { $0 }
    }
}
