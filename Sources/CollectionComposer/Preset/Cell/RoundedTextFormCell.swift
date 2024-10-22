//
//  RoundedTextFormCell.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/03.
//

import Combine
import UIKit

open class RoundedTextFormCell: UICollectionViewCell, TextFormCell, UITextFieldDelegate {
    // MARK: Lifecycle

    override public init(frame: CGRect) {
        super.init(frame: frame)

        let baseView = UIView(frame: .zero)
        baseView.backgroundColor = .tertiarySystemGroupedBackground
        baseView.layer.cornerRadius = 8
        baseView.translatesAutoresizingMaskIntoConstraints = false
        let textFieldBaseView = UIView(frame: .zero)
        textFieldBaseView.translatesAutoresizingMaskIntoConstraints = false
        textFieldBaseView.addSubview(textField)
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
            textField.trailingAnchor.constraint(equalTo: textFieldBaseView.trailingAnchor),
            textField.leadingAnchor.constraint(equalTo: textFieldBaseView.leadingAnchor),
            textField.centerYAnchor.constraint(equalTo: textFieldBaseView.centerYAnchor),
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

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public static let defaultTextFieldHeight: CGFloat = 30
    public static let defaultHeight: CGFloat = 50

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

    public func configure(_ form: TextForm) {
        cancellable.removeAll()
        self.form = form

        label.isHidden = form.label == nil
        if let labelText = form.label, labelText.isEmpty {
            label.isHidden = true
        }
        label.text = form.label
        textField.configure(form: form).store(in: &cancellable)
        form.shouldFocusTextFieldPublisher.sink { [weak self] _ in
            guard let self else {
                return
            }
            textField.becomeFirstResponder()
        }.store(in: &cancellable)
    }

    // MARK: Internal

    var shouldValidate = false

    var isSecureTextEntry: Bool {
        get {
            return textField.isSecureTextEntry
        }
        set {
            textField.isSecureTextEntry = newValue
        }
    }

    @objc @discardableResult
    func focus() -> Bool {
        return textField.becomeFirstResponder()
    }

    @discardableResult
    func resign() -> Bool {
        return textField.resignFirstResponder()
    }

    // MARK: Private

    private let contentInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    private var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var validationHintlabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.alpha = 0
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.textColor = .darkText
        return textField
    }()

    private var cancellable = Set<AnyCancellable>()

    @objc private func textDidChange(_ textField: UITextField) {
        validateText()
    }

    private func validateText() {
        if shouldValidate,
           let form,
           let handler = form.validationHandler {
            switch handler(form.currentInput) {
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
