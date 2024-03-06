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
        let attributedString = NSMutableAttributedString(
            string: "Hello",
            attributes: [
                .font: UIFont.systemFont(ofSize: 24.0),
                .foregroundColor: UIColor.orange,
                .strokeColor: UIColor.red,
                .paragraphStyle: {
                    let space = NSMutableParagraphStyle()
                    space.lineSpacing = 20
                    return space
                }()
            ]
        )
        attributedString.append(NSAttributedString(
            string: "World",
            attributes: [
                .font: UIFont.systemFont(ofSize: 35.0),
                .foregroundColor: UIColor.purple,
                .strokeColor: UIColor.blue,
                .strokeWidth: -2
            ]
        ))
        provider = self
        store {
            TextSection<BasicTextCell>("Sample Text")
            DividorSection()
            TextSection<BasicTextCell>(
                StringConfiguration(
                    .plain(text: "Bold Text", font: .boldSystemFont(ofSize: 30)),
                    textAlignment: .right
                ))
            DividorSection()
            TextSection<BasicTextCell>(StringConfiguration(.attributed(text: attributedString)))
            DividorSection()
            ActivityIndicatorSection()
            DividorSection()
            ButtonSection<BasicButtonCell>(
                id: "button",
                configuration: ButtonConfiguration(configuration: .filled(), title: "Button")
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
