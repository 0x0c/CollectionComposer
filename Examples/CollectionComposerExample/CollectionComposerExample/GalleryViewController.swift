//
//  GalleryViewController.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/02/29.
//

import CollectionComposer
import SwiftUI
import UIKit

class GalleryViewController: ComposedCollectionViewController, SectionProvider, SectionDataSource {
    private(set) var sections = [any CollectionComposer.Section]()

    lazy var sectionDataSource: CollectionComposer.SectionDataSource = self

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gallery"

        provider = self
        store {
            TextSection("Sample Text")
            DividorSection()
            TextSection(.init(text: "Sample Text", textAlignment: .right, font: .boldSystemFont(ofSize: 30)))
            DividorSection()
            ActivityIndicatorSection()
            DividorSection()
            ButtonSection(
                id: "button",
                configuration: ButtonSection.Configuration(configuration: .filled(), title: "Button")
            ) { id in
                print("button pressed \(id)")
            }
            DividorSection()
            SwiftUISection(
                id: "swift-ui-section",
                configuration: UIHostingConfiguration {
                    ContentUnavailableView {
                        Label(String(localized: "Not found"), systemImage: "magnifyingglass")
                    } description: {
                        VStack {
                            Text("SwiftUI Section Example")
                        }
                    }
                }
            )
        }
    }

    func store(_ sections: [any CollectionComposer.Section]) {
        self.sections = sections
    }
}
