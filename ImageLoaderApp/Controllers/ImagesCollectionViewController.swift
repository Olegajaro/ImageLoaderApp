//
//  ImagesCollectionViewController.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 25.10.2025.
//

import UIKit

final class ImagesCollectionViewController: UIViewController {
    // MARK: - UI Elements
    private var mainView: ImagesCollectionView {
        return view as! ImagesCollectionView
    }
    
    // MARK: - Properties
    private var presenter: ImagesPresenterProtocol?
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        view = ImagesCollectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.delegate = self
        setupDefaultPresenter()
        setupNavBar()
        setupCollectionView()
        presenter?.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mainView.invalidateLayout()
    }
}

// MARK: - Setup
private extension ImagesCollectionViewController {
    func setupDefaultPresenter() {
        if presenter == nil {
            let defaultPresenter = ImagesPresenter()
            defaultPresenter.setView(self)
            presenter = defaultPresenter
        }
    }
    
    func setupNavBar() {
        title = "Images"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    func setupCollectionView() {
        mainView.collectionView.dataSource = self
    }
}

// MARK: - ImagesCollectionViewDelegate
extension ImagesCollectionViewController: ImagesCollectionViewDelegate {
    func imagesCollectionViewDidPullToRefresh(_ view: ImagesCollectionView) {
        presenter?.didPullToRefresh()
    }
    
    func imagesCollectionView(_ view: ImagesCollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.didSelectItem(at: indexPath)
    }
    
    func imagesCollectionView(_ view: ImagesCollectionView,
                              willDisplayCell cell: ImageCollectionViewCell,
                              at indexPath: IndexPath) {
        presenter?.willDisplayCell(cell, at: indexPath)
    }
    
    func imagesCollectionView(_ view: ImagesCollectionView,
                              didEndDisplayingCellAt indexPath: IndexPath) {
        presenter?.didEndDisplayingCell(at: indexPath)
    }
}

// MARK: - ImagesViewProtocol
extension ImagesCollectionViewController: ImagesViewProtocol {
    func reloadData() {
        mainView.reloadData()
    }
    
    func reloadDataWithoutAnimation() {
        UIView.performWithoutAnimation {
            mainView.reloadData()
        }
    }
    
    func endRefreshing() {
        mainView.endRefreshing()
    }
    
    func performBatchUpdate(deleting indexPath: IndexPath, completion: ((Bool) -> Void)?) {
        mainView.performBatchUpdate(deleting: indexPath, completion: completion)
    }
    
    func invalidateLayout() {
        mainView.invalidateLayout()
    }
    
    func cellForItem(at indexPath: IndexPath) -> ImageCollectionViewCell? {
        return mainView.cellForItem(at: indexPath)
    }
    
    func animateCellDeletion(at indexPath: IndexPath, completion: @escaping () -> Void) {
        guard let cell = mainView.cellForItem(at: indexPath) else {
            completion()
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            let collectionWidth = self.mainView.collectionView.bounds.width
            cell.transform = CGAffineTransform(translationX: collectionWidth, y: 0)
            cell.alpha = 0.0
        }, completion: { _ in
            completion()
        })
    }
}

// MARK: - UICollectionViewDataSource
extension ImagesCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        presenter?.numberOfItems() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier,
            for: indexPath
        )
        return reuseCell
    }
}
