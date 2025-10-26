//
//  ImagesPresenter.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 26.10.2025.
//

import UIKit

protocol ImagesPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didPullToRefresh()
    func didSelectItem(at indexPath: IndexPath)
    func willDisplayCell(_ cell: ImageCollectionViewCell, at indexPath: IndexPath)
    func didEndDisplayingCell(at indexPath: IndexPath)
    func numberOfItems() -> Int
}

protocol ImagesViewProtocol: AnyObject {
    func reloadData()
    func reloadDataWithoutAnimation()
    func endRefreshing()
    func performBatchUpdate(deleting indexPath: IndexPath, completion: ((Bool) -> Void)?)
    func invalidateLayout()
    func cellForItem(at indexPath: IndexPath) -> ImageCollectionViewCell?
    func animateCellDeletion(at indexPath: IndexPath, completion: @escaping () -> Void)
}

final class ImagesPresenter {
    
    // MARK: - Dependencies
    private weak var view: ImagesViewProtocol?
    private let imageLoader: ImageLoaderProtocol
    private let imageURLProvider: ImageURLProviderProtocol
    
    // MARK: - Properties
    private var imageURLs: [URL] = []
    
    // MARK: - Init
    init(imageLoader: ImageLoaderProtocol = ImageLoader(),
         imageURLProvider: ImageURLProviderProtocol = ImageURLProvider()) {
        self.imageLoader = imageLoader
        self.imageURLProvider = imageURLProvider
    }
    
    func setView(_ view: ImagesViewProtocol) {
        self.view = view
    }
}

// MARK: - ImagesPresenterProtocol
extension ImagesPresenter: ImagesPresenterProtocol {
    func viewDidLoad() {
        loadInitialData()
    }
    
    func didPullToRefresh() {
        refreshData()
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        handleItemSelection(at: indexPath)
    }
    
    func willDisplayCell(_ cell: ImageCollectionViewCell, at indexPath: IndexPath) {
        loadImageForCell(cell, at: indexPath)
    }
    
    func didEndDisplayingCell(at indexPath: IndexPath) {
        cancelImageLoading(at: indexPath)
    }
    
    func numberOfItems() -> Int {
        imageURLs.count
    }
}

// MARK: - Private Methods
private extension ImagesPresenter {
    func loadInitialData() {
        imageURLs = imageURLProvider.getSimpleImageURLs()
    }
    
    func refreshData() {
        imageLoader.clearAllCaches()
        imageURLs = imageURLProvider.getSimpleImageURLs()
        view?.reloadDataWithoutAnimation()
        view?.endRefreshing()
    }
    
    func handleItemSelection(at indexPath: IndexPath) {
        guard let cell = view?.cellForItem(at: indexPath),
              cell.isImageLoaded else { return }
        
        view?.animateCellDeletion(at: indexPath) { [weak self] in
            self?.removeItem(at: indexPath)
        }
    }
    
    func removeItem(at indexPath: IndexPath) {
        guard indexPath.item < imageURLs.count else { return }
        imageURLs.remove(at: indexPath.item)
        view?.performBatchUpdate(deleting: indexPath, completion: nil)
    }
    
    func loadImageForCell(_ cell: ImageCollectionViewCell, at indexPath: IndexPath) {
        guard indexPath.item < imageURLs.count else { return }
        let url = imageURLs[indexPath.item]
        
        cell.showLoading()
        imageLoader.loadImage(from: url) { [weak cell] result in
            DispatchQueue.main.async {
                guard let cell = cell else { return }
                switch result {
                case .success(let image):
                    cell.configure(with: image)
                case .failure:
                    cell.configureWithPlaceholder()
                }
            }
        }
    }
    
    func cancelImageLoading(at indexPath: IndexPath) {
        guard indexPath.item < imageURLs.count else { return }
        let url = imageURLs[indexPath.item]
        imageLoader.cancelLoad(for: url)
    }
}
