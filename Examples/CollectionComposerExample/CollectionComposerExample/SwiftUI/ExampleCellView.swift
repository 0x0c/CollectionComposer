//
//  ExampleCellView.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/04/29.
//

import CollectionComposer
import SwiftUI

// MARK: - ExampleData

struct ExampleData: SwiftUICellViewModel, Hashable {
    let title: String

    var removeMergins: Bool { true }
}

// MARK: - ExampleCellView

struct ExampleCellView: SwiftUICellView {
    // MARK: Lifecycle

    init(_ model: ExampleData, isHighlighted: Bool = false) {
        self.model = model
        self.isHighlighted = isHighlighted
    }

    // MARK: Internal

    typealias Model = ExampleData

    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "list.clipboard")
            Text(model.title)
            Spacer()
        }
        .padding()
        .background(in: Rectangle())
        .backgroundStyle(isHighlighted ? Color.red : Color.clear)
    }

    // MARK: Private

    private var isHighlighted: Bool
    private var model: ExampleData
}

#Preview {
    ExampleCellView(ExampleData(title: "Example"))
}
