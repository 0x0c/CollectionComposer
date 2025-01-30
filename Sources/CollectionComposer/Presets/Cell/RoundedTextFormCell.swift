//
//  RoundedTextFormCell.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/03.
//

import Combine
import UIKit

/// A collection view cell with a rounded text input field, designed for form-like input in list or grid layouts.
///
/// `RoundedTextFormCell` is a subclass of `UICollectionViewCell` that conforms to `TextFormCell` and `UITextFieldDelegate`.
/// It provides a rounded text input field with optional validation hints, allowing users to enter and validate text.
/// This cell is intended for form-based input in collection views, supporting secure text entry, validation, and focus control.
open class RoundedTextFormCell: UICollectionViewCell, TextFormCell, UITextFieldDelegate {
    // MARK: Lifecycle

    /// Initializes a new rounded text form cell with the specified frame.
    ///
    /// This initializer sets up the cell layout, including the input field, label, and validation hint label,
    /// and configures constraints to create a rounded, embedded text field layout.
    ///
    /// - Parameter frame: The frame rectangle for the cell, measured in points.
    override public init(frame: CGRect) {
        super.init(frame: frame)

        let baseView = UIView(frame: .zero)
        baseView.backgroundColor = .tertiarySystemGroupedBackground
        baseView.layer.cornerRadius = 8
        baseView.translatesAutoresizingMaskIntoConstraints = false
        let textFieldBaseView = UIView(frame: .zero)
        textFieldBaseView.translatesAutoresizingMaskIntoConstraints = false
        textFieldBaseView.addSubview(inputField)

        let baseStackView = UIStackView(arrangedSubviews: [
            validationHintlabel,
            textFieldBaseView
        ])
        validationHintlabel.heightAnchor.constraint(
            equalToConstant: validationHintlabel.font.pointSize + 2
        ).isActive = true
        validationHintlabel.isUserInteractionEnabled = true
        validationHintlabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(focus))
        )
        baseStackView.translatesAutoresizingMaskIntoConstraints = false
        baseStackView.axis = .vertical
        baseStackView.distribution = .fill
        baseStackView.clipsToBounds = true
        baseView.addSubview(baseStackView)
        NSLayoutConstraint.activate([
            inputField.trailingAnchor.constraint(equalTo: textFieldBaseView.trailingAnchor),
            inputField.leadingAnchor.constraint(equalTo: textFieldBaseView.leadingAnchor),
            inputField.centerYAnchor.constraint(equalTo: textFieldBaseView.centerYAnchor),

            baseStackView.topAnchor.constraint(
                equalTo: baseView.topAnchor,
                constant: contentInset.top
            ),
            baseStackView.bottomAnchor.constraint(
                equalTo: baseView.bottomAnchor,
                constant: -contentInset.bottom
            ),
            baseStackView.trailingAnchor.constraint(
                equalTo: baseView.trailingAnchor,
                constant: -contentInset.right
            ),
            baseStackView.leadingAnchor.constraint(
                equalTo: baseView.leadingAnchor,
                constant: contentInset.left
            )
        ])
        let stackView = UIStackView(arrangedSubviews: [
            label,
            baseView
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8

        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            baseView.heightAnchor.constraint(
                equalToConstant: RoundedTextFormCell.defaultTextFieldHeight + validationHintlabel.font.pointSize + 2
            ),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    /// Unavailable initializer.
    ///
    /// This initializer is unavailable and will trigger a fatal error if called.
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    /// The default height for the text field.
    public static let defaultTextFieldHeight: CGFloat = 30

    /// The default height for the cell.
    public static let defaultHeight: CGFloat = 50

    /// The form object that manages the text input and validation for the cell.
    public var form: TextForm?

    /// The text input field in the cell.
    ///
    /// The `inputField` is configured for text input, with optional secure entry and validation.
    public private(set) lazy var inputField: InputField = {
        let textField = InputField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.textColor = .darkText
        textField.originalDelegate = self
        return textField
    }()

    public func didUpdateFormInput(_ input: TextForm.Input?) {
        validateText()
    }

    /// Called when the text field finishes editing.
    ///
    /// This method triggers validation when editing ends.
    /// - Parameter textField: The text field that ended editing.
    public func textFieldDidEndEditing(_ textField: UITextField) {
        shouldValidate = true
        validateText()
    }

    /// Called when the return button is pressed in the text field.
    ///
    /// This method moves the focus to the next input field if available, otherwise, it resigns focus.
    /// - Parameter textField: The text field in which the return button was pressed.
    /// - Returns: A Boolean indicating whether the text field should process the return press.
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

    /// Configures the cell with the specified form.
    ///
    /// This method sets up the cell with the provided `TextForm` object and binds it for input and validation.
    /// - Parameter form: The form object managing the cell's input and validation.
    public func configure(_ form: TextForm) {
        cancellable.removeAll()
        self.form = form

        label.isHidden = form.label == nil
        if let labelText = form.label, labelText.isEmpty {
            label.isHidden = true
        }
        label.text = form.label

        form.bind(self).store(in: &cancellable)
        form.shouldFocusTextFieldPublisher.sink { [weak self] _ in
            guard let self else {
                return
            }
            inputField.becomeFirstResponder()
        }.store(in: &cancellable)
    }

    // MARK: Internal

    /// Indicates whether validation should be performed.
    var shouldValidate = false

    /// A Boolean indicating whether the text entry is secure.
    var isSecureTextEntry: Bool {
        get {
            return inputField.isSecureTextEntry
        }
        set {
            inputField.isSecureTextEntry = newValue
        }
    }

    /// Sets the focus on the input field.
    ///
    /// - Returns: A Boolean indicating whether the input field became the first responder.
    @objc @discardableResult
    func focus() -> Bool {
        return inputField.becomeFirstResponder()
    }

    /// Resigns the focus from the input field.
    ///
    /// - Returns: A Boolean indicating whether the input field resigned as the first responder.
    @discardableResult
    func resign() -> Bool {
        return inputField.resignFirstResponder()
    }

    // MARK: Private

    /// Insets for the cell content.
    private let contentInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    /// The label displayed at the top of the cell.
    private var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// The validation hint label displayed below the text field.
    private var validationHintlabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.alpha = 0
        return label
    }()

    /// A set of cancellable bindings for managing publisher subscriptions.
    private var cancellable = Set<AnyCancellable>()

    /// Handles changes to the text input and triggers validation.
    ///
    /// - Parameter textField: The text field in which the text changed.
    @objc private func textDidChange(_ textField: UITextField) {
        guard let form else {
            return
        }
        if form.inputStyle.needsKeyboard, let text = textField.text {
            form.currentInput = .text(text)
        }
        validateText()
    }

    /// Validates the current text in the input field.
    ///
    /// This method checks the input against the form's validation handler and updates
    /// the visibility of the validation hint label based on the result.
    private func validateText() {
        if shouldValidate,
           let form,
           let handler = form.validationHandler {
            switch handler(form) {
            case .valid:
                validationHintlabel.isHidden = true
                validationHintlabel.alpha = 0
            case let .invalid(hint):
                validationHintlabel.isHidden = false
                validationHintlabel.alpha = 1
                validationHintlabel.text = hint
            }
        }
        else {
            validationHintlabel.alpha = 0
            validationHintlabel.isHidden = true
        }
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 1,
            animations: { [unowned self] in
                setNeedsLayout()
                layoutIfNeeded()
            }
        )
    }
}
