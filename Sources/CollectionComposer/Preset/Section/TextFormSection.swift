//
//  TextFormSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/01.
//

import Combine
import UIKit

// MARK: - TextFormSection

open class TextFormSection: Section {
    // MARK: Lifecycle

    public init(id: String, @ItemBuilder<TextForm> _ items: () -> [TextForm]) {
        self.id = id
        self.items = items()
        self.items.linkForms()
    }

    // MARK: Open

    open class TextFormCell: UICollectionViewCell, UITextFieldDelegate {
        // MARK: Lifecycle

        override public init(frame: CGRect) {
            super.init(frame: frame)
            label.font = .preferredFont(forTextStyle: .headline)
            textField.delegate = self
            textField.addTarget(
                self,
                action: #selector(textDidChange),
                for: .editingChanged
            )
            textField.translatesAutoresizingMaskIntoConstraints = false
            let baseView = UIView(frame: .zero)
            baseView.backgroundColor = .tertiarySystemGroupedBackground
            baseView.layer.cornerRadius = 8
            baseView.translatesAutoresizingMaskIntoConstraints = false
            baseView.addSubview(textField)
            NSLayoutConstraint.activate([
                textField.heightAnchor.constraint(
                    equalToConstant: TextFormCell.defaultHeight
                ),
                textField.topAnchor.constraint(equalTo: baseView.topAnchor),
                textField.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),
                textField.trailingAnchor.constraint(
                    equalTo: baseView.trailingAnchor,
                    constant: -16
                ),
                textField.leadingAnchor.constraint(
                    equalTo: baseView.leadingAnchor,
                    constant: 16
                )
            ])
            let stackView = UIStackView(arrangedSubviews: [
                label,
                baseView
            ])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(stackView)
            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.spacing = 8
            NSLayoutConstraint.activate([
                baseView.heightAnchor.constraint(equalToConstant: TextFormCell.defaultHeight),
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
            ])
        }

        @available(*, unavailable)
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: Public

        public var form: TextForm?

        public func textFieldDidEndEditing(_ textField: UITextField) {
            shouldValidate = true
            validateText()
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            shouldValidate = true
            guard let form else {
                return true
            }
            validateText()
            if form.focuseNext() == false {
                resign()
            }
            return true
        }

        // MARK: Internal

        static let defaultHeight: CGFloat = 44

        var shouldValidate = false

        var isSecureTextEntry: Bool {
            get {
                return textField.isSecureTextEntry
            }
            set {
                textField.isSecureTextEntry = newValue
            }
        }

        func configure(_ form: TextForm) {
            cancellable.removeAll()
            self.form = form
            form.$text
                .assign(to: \UITextField.text, on: textField)
                .store(in: &cancellable)

            label.isHidden = form.label == nil
            if let labelText = form.label, labelText.isEmpty {
                label.isHidden = true
            }
            label.text = form.label
            textField.isSecureTextEntry = form.isSecureText
            textField.placeholder = form.placeholder
            textField.keyboardType = form.keyboardType
            textField.spellCheckingType = form.spellCheckingType
            textField.autocorrectionType = form.autocorrectionType
            textField.autocapitalizationType = form.autocapitalizationType
            form.shouldFocusTextFieldPublisher.sink { [weak self] _ in
                guard let self else {
                    return
                }
                textField.becomeFirstResponder()
            }.store(in: &cancellable)
        }

        @discardableResult
        func focuse() -> Bool {
            return textField.becomeFirstResponder()
        }

        @discardableResult
        func resign() -> Bool {
            return textField.resignFirstResponder()
        }

        // MARK: Private

        private var label = UILabel(frame: .zero)
        private var textField = UITextField(frame: .zero)
        private var cancellable = Set<AnyCancellable>()

        @objc private func textDidChange(_ textField: UITextField) {
            validateText()
        }

        private func validateText() {
            if shouldValidate,
               let form,
               let handler = form.validationHandler,
               handler(textField.text) == false {
                textField.textColor = .systemRed
            }
            else {
                textField.textColor = .darkText
            }
        }
    }

    open var cellRegistration: UICollectionView.CellRegistration<
        TextFormCell, TextForm
    >! = UICollectionView.CellRegistration<TextFormCell, TextForm> { cell, _, model in
        cell.configure(model)
    }

    open var isExpanded = false
    open var isExpandable = false

    open private(set) var items = [TextForm]()

    open var id: String

    open var snapshotItems: [AnyHashable] {
        return items
    }

    open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(TextFormCell.defaultHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(TextFormCell.defaultHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        return section
    }

    open func isHighlightable(for index: Int) -> Bool {
        return false
    }

    // MARK: Public

    public class TextForm: Hashable {
        // MARK: Lifecycle

        public init(
            label: String? = nil,
            text: String? = nil,
            placeholder: String? = nil,
            isSecureText: Bool = false,
            keyboardType: UIKeyboardType = .default,
            spellCheckingType: UITextSpellCheckingType = .default,
            autocorrectionType: UITextAutocorrectionType = .default,
            autocapitalizationType: UITextAutocapitalizationType = .none,
            contentType: UITextContentType? = nil
        ) {
            self.label = label
            self.text = text
            self.placeholder = placeholder
            self.isSecureText = isSecureText
            self.keyboardType = keyboardType
            self.spellCheckingType = spellCheckingType
            self.autocorrectionType = autocorrectionType
            self.autocapitalizationType = autocapitalizationType
            self.contentType = contentType
        }

        // MARK: Public

        public lazy var shouldFocusTextFieldPublisher = _shouldFocusTextFieldSubject.eraseToAnyPublisher()
        public var label: String?
        @Published public var text: String?
        public var placeholder: String?
        public var isSecureText: Bool
        public var keyboardType: UIKeyboardType = .default
        public var spellCheckingType: UITextSpellCheckingType = .default
        public var autocorrectionType: UITextAutocorrectionType = .default
        public var autocapitalizationType: UITextAutocapitalizationType = .sentences
        public var contentType: UITextContentType?
        public var validationHandler: ((String?) -> Bool)?

        public static func == (lhs: TextFormSection.TextForm, rhs: TextFormSection.TextForm) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        @discardableResult
        public func validate(_ handler: @escaping (String?) -> Bool) -> Self {
            validationHandler = handler
            return self
        }

        @discardableResult
        public func focuseNext() -> Bool {
            guard let next else {
                return false
            }
            next._shouldFocusTextFieldSubject.send(())
            return true
        }

        @discardableResult
        public func focusePrevious() -> Bool {
            guard let previous else {
                return false
            }
            previous._shouldFocusTextFieldSubject.send(())
            return true
        }

        // MARK: Internal

        var next: TextForm?
        var previous: TextForm?

        // MARK: Private

        private var _shouldFocusTextFieldSubject = PassthroughSubject<Void, Never>()
        private let id = UUID()
    }
}

extension [TextFormSection.TextForm] {
    func linkForms() {
        var iterator = makeIterator()
        var current: TextFormSection.TextForm? = iterator.next()
        var previous: TextFormSection.TextForm?
        while let next = iterator.next() {
            current?.previous = previous
            current?.next = next
            previous = current
            current = next
        }
    }
}
