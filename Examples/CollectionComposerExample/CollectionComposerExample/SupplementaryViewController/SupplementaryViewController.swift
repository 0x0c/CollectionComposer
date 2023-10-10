//
//  SupplementaryViewController.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2023/10/09.
//

import CollectionComposer
import UIKit

class SupplementaryViewController: ComposedCollectionViewController, SectionProvider, SectionDataSource {
    var sections = [any Section]()

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
            }
        }
    }
}
