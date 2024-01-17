//
//  ComposedCollectionViewController.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/04.
//

import Combine
import UIKit

// MARK: - ComposedCollectionViewController

open class ComposedCollectionViewController: UIViewController {
    // MARK: Open

    override open func viewDidLoad() {
        super.viewDidLoad()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout(configuration: layoutConfiguration()))
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.delaysContentTouches = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        dataSource = UICollectionViewDiffableDataSource<AnyHashable, AnyHashable>(
            collectionView: collectionView
        ) { [unowned self] _, indexPath, item -> UICollectionViewCell? in
            return cell(for: indexPath, item: item)
        }
        dataSource.supplementaryViewProvider = { [unowned self] _, kind, indexPath in
            return supplementaryView(for: kind, indexPath: indexPath)
        }
        dataSource.sectionSnapshotHandlers.willCollapseItem = { [unowned self] item in
            guard var section = provider?.sectionDataSource.sections.first(where: {
                $0.snapshotSection.hashValue == item.hashValue
            }) else {
                return
            }
            section.isExpanded = false
        }
        dataSource.sectionSnapshotHandlers.willExpandItem = { [unowned self] item in
            guard var section = provider?.sectionDataSource.sections.first(where: {
                $0.snapshotSection.hashValue == item.hashValue
            }) else {
                return
            }
            section.isExpanded = true
        }
    }

    open func cell(for indexPath: IndexPath, item: AnyHashable) -> UICollectionViewCell? {
        return provider?
            .sectionDataSource
            .section(for: indexPath.section)
            .cell(for: indexPath, in: collectionView, item: item)
    }

    open func supplementaryView(for kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        guard let view = provider?
            .sectionDataSource
            .section(for: indexPath.section)
            .supplementaryView(
                collectionView,
                kind: kind,
                indexPath: indexPath
            ) else {
            return nil
        }
        return view
    }

    open func layoutConfiguration() -> UICollectionViewCompositionalLayoutConfiguration {
        return UICollectionViewCompositionalLayoutConfiguration()
    }

    open func updateDataSource(_ sections: [any Section], animateWhenUpdate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<AnyHashable, AnyHashable>()
        let appendSections = sections.filter {
            if ignoreEmptySection {
                return $0.snapshotItems.isEmpty == false
            }
            return true
        }
        snapshot.appendSections(appendSections.map(\.snapshotSection))
        for section in appendSections where section.isExpandable == false {
            snapshot.appendItems(section.snapshotItems, toSection: section.snapshotSection)
        }
        dataSource.apply(snapshot, animatingDifferences: animateWhenUpdate)
        for section in appendSections where section.isExpandable {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
            sectionSnapshot.append([section.snapshotSection])
            sectionSnapshot.append(section.snapshotItems, to: section.snapshotSection)
            if section.isExpanded {
                sectionSnapshot.expand([section.snapshotSection])
            }
            else {
                sectionSnapshot.collapse([section.snapshotSection])
            }
            dataSource.apply(sectionSnapshot, to: section.snapshotSection, animatingDifferences: animateWhenUpdate)
        }
    }

    open func reloadSections(animate: Bool = true) {
        if let provider {
            updateDataSource(provider.sectionDataSource.sections, animateWhenUpdate: animate)
        }
    }

    open func didSelectItem(_ item: AnyHashable, in section: any Section, at indexPath: IndexPath) {}

    // MARK: Public

    public var collectionView: UICollectionView!
    public var highlightedColor: UIColor?
    public var dataSource: UICollectionViewDiffableDataSource<AnyHashable, AnyHashable>!
    public var ignoreEmptySection = false

    public weak var provider: SectionProvider? {
        didSet {
            cancellable.removeAll()
            if let provider {
                provider.storePublisher
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] animate in
                        guard let self else {
                            return
                        }
                        reloadSections(animate: animate)
                    }.store(in: &cancellable)
            }
        }
    }

    // MARK: Private

    private var cancellable = Set<AnyCancellable>()

    private func layout(configuration: UICollectionViewCompositionalLayoutConfiguration) -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { [unowned self] sectionIndex, environment -> NSCollectionLayoutSection? in
            return provider?
                .sectionDataSource
                .section(for: sectionIndex)
                .layoutSection(for: environment)
        }, configuration: configuration)
    }
}

// MARK: UICollectionViewDelegate

extension ComposedCollectionViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = provider?.sectionDataSource.section(for: indexPath.section),
              let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        didSelectItem(item, in: section, at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let section = provider?.sectionDataSource.section(for: indexPath.section) else {
            return false
        }
        return section.isHighlightable(for: indexPath.row)
    }
}
