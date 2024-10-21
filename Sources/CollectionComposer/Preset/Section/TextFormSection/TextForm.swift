//
//  TextForm.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/03.
//

import Combine
import UIKit

open class TextForm: Hashable {
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

    public enum ValidationResult {
        case valid
        case invalid(hint: String)
    }

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
    public var validationHandler: ((String?) -> ValidationResult)?

    public static func == (lhs: TextForm, rhs: TextForm) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    @discardableResult
    open func validate(_ handler: @escaping (String?) -> ValidationResult) -> Self {
        validationHandler = handler
        return self
    }

    @discardableResult
    open func focuseNext() -> Bool {
        guard let next else {
            return false
        }
        next._shouldFocusTextFieldSubject.send(())
        return true
    }

    @discardableResult
    open func focusePrevious() -> Bool {
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
