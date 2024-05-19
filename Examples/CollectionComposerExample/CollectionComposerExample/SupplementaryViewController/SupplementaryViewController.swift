//
//  SupplementaryViewController.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2023/10/09.
//

import CollectionComposer
import UIKit

class SupplementaryViewController: ComposedCollectionViewController, SectionProvider, SectionDataSource {
    private(set) var sections = [any Section]()

    lazy var sectionDataSource: CollectionComposer.SectionDataSource = self

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Supplementary"

        provider = self
        store {
            SupplementarySection(id: "First") {
                for index in 0 ... 50 {
                    SupplementarySection.Model(title: "\(index)")
                }
            }
            SupplementarySection(id: "Second") {
                for index in 0 ... 50 {
                    SupplementarySection.Model(title: "\(index)")
                }
            }.header(PlainHeaderView("PlainHeader"))
        }
    }

    func store(_ sections: [any CollectionComposer.Section]) {
        self.sections = sections
    }
}
