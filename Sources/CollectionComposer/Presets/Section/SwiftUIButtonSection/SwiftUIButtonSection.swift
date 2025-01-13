//
//  SwiftUIButtonSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/09/28.
//

import SwiftUI

@available(iOS 16.0, *)
public class SwiftUIButtonSection<Content: View>: SwiftUISection {
    // MARK: Lifecycle

    override private init(id: String, configuration: Configuration = .defaultConfiguration(), item: ViewConfiguration) {
        super.init(id: id, configuration: configuration, item: item)
    }

    private convenience init(id: String, configuration: Configuration = .defaultConfiguration(), contentConfiguration: UIContentConfiguration) {
        self.init(id: id, configuration: configuration, item: ViewConfiguration(contentConfiguration))
    }

    @available(iOS 16.0, *)
    private convenience init(id: String, configuration: Configuration = .defaultConfiguration(), @ViewBuilder content: () -> some View) {
        let viewConfiguration = if configuration.removeMargins {
            ViewConfiguration(UIHostingConfiguration { content() }.margins(.all, 0))
        }
        else {
            ViewConfiguration(UIHostingConfiguration { content() })
        }
        self.init(
            id: id,
            configuration: configuration,
            item: viewConfiguration
        )
    }

    public convenience init(
        id: String,
        state: SwiftUIButtonState,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Content
    ) {
        self.init(id: id, configuration: .defaultConfiguration(removeMargins: true)) {
            InternalButton(state: state, action: action, label: label)
        }
    }

    public convenience init(
        id: String,
        state: SwiftUIButtonState,
        style: some ButtonStyle,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Content
    ) {
        self.init(id: id, configuration: .defaultConfiguration(removeMargins: true)) {
            InternalButton(state: state, action: action, label: label)
                .buttonStyle(style)
        }
    }

    public convenience init(
        id: String,
        state: SwiftUIButtonState,
        style: some PrimitiveButtonStyle,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Content
    ) {
        self.init(id: id, configuration: .defaultConfiguration(removeMargins: true)) {
            InternalButton(state: state, action: action, label: label)
                .buttonStyle(style)
        }
    }

    // MARK: Private

    private struct InternalButton: View {
        @ObservedObject var state: SwiftUIButtonState

        let action: () -> Void
        let label: () -> Content

        var body: some View {
            Button {
                action()
            } label: {
                label()
            }.disabled(state.isEnabled == false)
        }
    }
}
