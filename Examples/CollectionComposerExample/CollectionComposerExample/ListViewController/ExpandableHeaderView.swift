//
//  ExpandableHeaderView.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/10/05.
//

import CollectionComposer
import SwiftUI

// MARK: - ExpandableHeaderView

class ExpandableHeaderView: SwiftUISupllementaryHeaderView, ExpandableHeader {
    // MARK: Lifecycle

    init() {
        super.init(elementKind: "ExpandableHeaderView") { EmptyView() }
    }

    @available(*, unavailable)
    @MainActor required init(elementKind: String, pinToVisibleBounds: Bool = false, absoluteOffset: CGPoint = .zero, removeMargins: Bool = true, extendsBoundary: Bool = true, @ViewBuilder content: () -> some View) {
        fatalError("init(elementKind:pinToVisibleBounds:absoluteOffset:removeMargins:extendsBoundary:content:) has not been implemented")
    }

    @available(*, unavailable)
    @MainActor required init(elementKind: String, pinToVisibleBounds: Bool = false, absoluteOffset: CGPoint = .zero, extendsBoundary: Bool = true, configuration: (any UIContentConfiguration)? = nil) {
        fatalError("init(elementKind:pinToVisibleBounds:absoluteOffset:extendsBoundary:configuration:) has not been implemented")
    }

    // MARK: Public

    override public var headerMode: UICollectionLayoutListConfiguration.HeaderMode { .none }

    // MARK: Internal

    nonisolated var isExpandable: Bool { true }
    nonisolated var accessories: [UICellAccessory] {
        [.outlineDisclosure(options: UICellAccessory.OutlineDisclosureOptions(style: .header, tintColor: .clear))]
    }

    nonisolated func headerConfiguration() -> (any UIContentConfiguration)? {
        return UIHostingConfiguration {
            ExpandableHeaderInnerView(isExpanded: false)
        }
    }

    nonisolated func update(using state: UICellConfigurationState) -> (any UIContentConfiguration)? {
        return UIHostingConfiguration {
            ExpandableHeaderInnerView(isExpanded: state.isExpanded)
        }
    }
}

// MARK: - ExpandableHeaderInnerView

struct ExpandableHeaderInnerView: View {
    var isExpanded: Bool

    var body: some View {
        HStack {
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .animation(.easeInOut(duration: 0.25), value: isExpanded)
            VStack {
                Text("Hello, World!")
                Text("Hello, World!")
                Text("Hello, World!")
            }
        }
    }
}

#Preview {
    ExpandableHeaderInnerView(isExpanded: true)
}
