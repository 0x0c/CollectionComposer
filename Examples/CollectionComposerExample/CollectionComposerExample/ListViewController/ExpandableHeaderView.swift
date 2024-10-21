//
//  ExpandableHeaderView.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/10/05.
//

import CollectionComposer
import SwiftUI

// MARK: - ExpandableHeaderView

class ExpandableHeaderView: SwiftUISupllementaryHeaderView<UICollectionViewListCell>, ExpandableHeader {
    // MARK: Lifecycle

    init() {
        super.init(elementKind: "ExpandableHeaderView", content: { EmptyView().frame(height: 0) })
    }

    @available(*, unavailable)
    required init(
        elementKind: String,
        pinToVisibleBounds: Bool = false,
        absoluteOffset: CGPoint = .zero,
        removeMargins: Bool = true,
        extendsBoundary: Bool = true,
        @ViewBuilder content: () -> some View
    ) {
        fatalError()
    }

    @available(*, unavailable)
    required init(
        elementKind: String,
        pinToVisibleBounds: Bool = false,
        absoluteOffset: CGPoint = .zero,
        extendsBoundary: Bool = true,
        configuration: (any UIContentConfiguration)? = nil
    ) {
        fatalError()
    }

    // MARK: Public

    override public var headerMode: UICollectionLayoutListConfiguration.HeaderMode { .none }

    // MARK: Internal

    nonisolated var isExpandable: Bool { true }
    nonisolated var accessories: [UICellAccessory] {
        [.outlineDisclosure(options: UICellAccessory.OutlineDisclosureOptions(style: .header, tintColor: .clear))]
    }

    nonisolated var topSeparatorVisibility: UIListSeparatorConfiguration.Visibility { .hidden }
    nonisolated var bottomSeparatorVisibility: UIListSeparatorConfiguration.Visibility { .hidden }

    nonisolated func headerConfiguration(isExpanded: Bool) -> (any UIContentConfiguration)? {
        return UIHostingConfiguration {
            ExpandableHeaderInnerView(isExpanded: isExpanded)
        }
    }

    nonisolated func update(using state: UICellConfigurationState) -> (any UIContentConfiguration)? {
        return UIHostingConfiguration {
            ExpandableHeaderInnerView(isExpanded: state.isExpanded)
        }
    }

    // MARK: Private

    private var headerConfiguration: (any UIContentConfiguration)?
}

// MARK: - ExpandableHeaderInnerView

struct ExpandableHeaderInnerView: View {
    // MARK: Internal

    var isExpanded: Bool

    var body: some View {
        HStack {
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .animation(.easeInOut(duration: 0.25), value: isExpanded)
                .padding()
            Toggle(isOn: $isOn) {
                Text("SwiftUI expandable header")
            }
        }
    }

    // MARK: Private

    @State private var isOn = false
}

#Preview {
    ExpandableHeaderInnerView(isExpanded: true)
}
