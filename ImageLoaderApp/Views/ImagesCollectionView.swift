//
//  ImagesCollectionView.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 26.10.2025.
//

import UIKit

protocol ImagesCollectionViewDelegate: AnyObject {
    func imagesCollectionViewDidPullToRefresh(_ view: ImagesCollectionView)
    func imagesCollectionView(_ view: ImagesCollectionView,
                              didSelectItemAt indexPath: IndexPath)
    func imagesCollectionView(_ view: ImagesCollectionView,
                              willDisplayCell cell: ImageCollectionViewCell,
                              at indexPath: IndexPath)
    func imagesCollectionView(_ view: ImagesCollectionView,
                              didEndDisplayingCellAt indexPath: IndexPath)
}

final class ImagesCollectionView: UIView {
    
    // MARK: - UI Elements
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: createCollectionLayout())
        configureCollectionView(collectionView)
        return collectionView
    }()
    
    private(set) lazy var refreshControl: UIRefreshControl = .init()
    
    // MARK: - Properties
    weak var delegate: ImagesCollectionViewDelegate?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func performBatchUpdate(deleting indexPath: IndexPath, completion: ((Bool) -> Void)? = nil) {
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [indexPath])
        }, completion: completion)
    }
    
    func cellForItem(at indexPath: IndexPath) -> ImageCollectionViewCell? {
        return collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
    }
}

// MARK: - Setup & Configuration
private extension ImagesCollectionView {
    func setupViews() {
        backgroundColor = .systemBackground
        addCollectionView()
        setupRefreshControl()
        setupConstraints()
    }
    
    func addCollectionView() {
        collectionView.refreshControl = refreshControl
        addSubview(collectionView)
    }
    
    func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    func createCollectionLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return layout
    }
    
    func configureCollectionView(_ collectionView: UICollectionView) {
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(ImageCollectionViewCell.self,
                                forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier)
    }
    
    @objc
    func handleRefresh() {
        delegate?.imagesCollectionViewDidPullToRefresh(self)
    }
}

// MARK: - UICollectionViewDelegate
extension ImagesCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.imagesCollectionView(self, didSelectItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       willDisplay cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ImageCollectionViewCell else { return }
        delegate?.imagesCollectionView(self, willDisplayCell: cell, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       didEndDisplaying cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath) {
        delegate?.imagesCollectionView(self, didEndDisplayingCellAt: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ImagesCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontalPadding: CGFloat = 20.0
        let width = collectionView.bounds.width - totalHorizontalPadding
        return CGSize(width: width, height: width)
    }
}
