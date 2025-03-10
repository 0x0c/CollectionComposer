//
//  ExampleCellView.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/04/29.
//

import CollectionComposer
import SwiftUI

// MARK: - ExampleData

struct ExampleData: SwiftUICellViewEntity, Hashable {
    let title: String

    var canMove: Bool = .random()

    var removeMargins: Bool { true }

    var accessories: [UICellAccessory] {
        if canMove {
            return [.reorder(displayed: .always)]
        }
        return []
    }
}

// MARK: - ExampleCellView

struct ExampleCellView: SwiftUIListCellView {
    // MARK: Lifecycle

    init(_ model: ExampleData) {
        self.model = model
    }

    // MARK: Internal

    typealias Model = ExampleData

    var body: some View {
        HStack {
            Image(systemName: "list.clipboard")
            Text(model.title)
        }
        .padding()
    }

    // MARK: Private

    private var model: ExampleData
}

#Preview {
    ExampleCellView(ExampleData(title: "Example"))
}
