//
//  SectionProvider.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/04.
//

import Combine
import Foundation

// MARK: - SectionProvider

/// `SectionProvider` is a protocol to store sections in SectionDataSource and notify changes of data soruce.
public protocol SectionProvider: AnyObject {
    /// A data source for sections.
    var sectionDataSource: SectionDataSource { get }
    /// A publisher to notify changes of data source.
    var storePublisher: AnyPublisher<Bool, Never> { get }

    /// A function to store sections into the data source.
    /// - Parameters:
    ///   - animate: If true, the collection view is being added to the sections using an animation.
    ///   - sections: Sections that will be stored into the data source.
    func store(animate: Bool, @SectionBuilder _ sections: () -> [any Section])

    /// A function to store sections into the data source.
    /// - Parameters:
    ///   - animate: If true, the collection view is being added to the sections using an animation.
    ///   - sections: Sections that will be stored into the data source.
    func store(animate: Bool, sections: [any Section])
}

var nonceKey: UInt8 = 0
public extension SectionProvider {
    var storeSubject: PassthroughSubject<Bool, Never> {
        guard let associatedObject = objc_getAssociatedObject(
            self,
            &nonceKey
        ) as? PassthroughSubject<Bool, Never> else {
            let subject = PassthroughSubject<Bool, Never>()
            objc_setAssociatedObject(
                self,
                &nonceKey,
                subject,
                .OBJC_ASSOCIATION_RETAIN
            )
            return subject
        }
        return associatedObject
    }

    var storePublisher: AnyPublisher<Bool, Never> {
        return storeSubject.eraseToAnyPublisher()
    }

    func store(animate: Bool = true, @SectionBuilder _ sections: () -> [any Section]) {
        sectionDataSource.store(sections())
        storeSubject.send(animate)
    }

    func store(animate: Bool = true, sections: [any Section]) {
        sectionDataSource.store(sections)
        storeSubject.send(animate)
    }
}
