//
//  LogInFormViewController.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/03/01.
//

import CollectionComposer
import UIKit

class LogInFormViewController: ComposedCollectionViewController, SectionProvider, SectionDataSource {
    private(set) var sections = [any CollectionComposer.Section]()

    lazy var sectionDataSource: CollectionComposer.SectionDataSource = self

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log in"

        provider = self
        store {
            TextFormSection(id: "login") {
                TextFormSection.TextForm(label: "Username", placeholder: "Your name")
                TextFormSection.TextForm(placeholder: "Email").validate { text in
                    guard let text else {
                        return false
                    }
                    return text.count >= 10
                }
                TextFormSection.TextForm(placeholder: "Password", isSecureText: true)
            }
        }
    }

    func store(_ sections: [any CollectionComposer.Section]) {
        self.sections = sections
    }
}
