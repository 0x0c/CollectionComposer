//
//  ExampleCellView.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/04/29.
//

import CollectionComposer
import SwiftUI

// MARK: - ExampleData

struct ExampleData: Hashable {
    let title: String
}

// MARK: - ExampleCellView

struct ExampleCellView: SwiftUI.View, SwiftUICellView {
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
        .foregroundStyle(Color(uiColor: .label))
        .padding()
        .border(Color.black)
    }

    // MARK: Private

    private var model: ExampleData
}

#Preview {
    ExampleCellView(ExampleData(title: "Example"))
}
