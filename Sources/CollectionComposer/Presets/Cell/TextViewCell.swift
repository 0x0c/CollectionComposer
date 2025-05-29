//
//  TextViewCell.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2025/05/29.
//

import UIKit

open class TextViewCell: UICollectionViewCell {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        textView = UITextView(frame: frame)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        contentView.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Open

    open var text: StringRepresentation? {
        didSet {
            updateText()
        }
    }

    override open func prepareForReuse() {
        super.prepareForReuse()
        updateText()
    }

    // MARK: Private

    private var textView: UITextView!

    private func updateText() {
        switch text {
        case let .plain(text, font):
            textView.text = text
            textView.font = font
        case let .attributed(attributedString):
            textView.attributedText = attributedString
        case .none:
            textView.text = nil
        }
        let height = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        textView.heightAnchor.constraint(equalToConstant: height + 8).isActive = true
    }
}
