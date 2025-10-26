//
//  ImagesCollectionViewController.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 25.10.2025.
//

import UIKit

final class ImagesCollectionViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCollectionViewCell.self,
                                forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let imageLoader = ImageLoader()
    private var imageURLs = [
        URL(string: "https://placehold.co/800x600/1E90FF/FFFFFF/png?text=Ocean+Blue")!,
        URL(string: "https://placehold.co/800x600/FF8C00/FFFFFF/png?text=Sunset+Orange")!,
        URL(string: "https://placehold.co/800x600/32CD32/FFFFFF/png?text=Fresh+Green")!,
        URL(string: "https://placehold.co/800x600/8A2BE2/FFFFFF/png?text=Purple+Vibe")!,
        URL(string: "https://placehold.co/800x600/DC143C/FFFFFF/png?text=Crimson+Red")!,
        URL(string: "https://placehold.co/800x600/2F4F4F/FFFFFF/png?text=Dark+Slate")!,
    ]
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - Setup Views & Helpers
private extension ImagesCollectionViewController {
    func setupViews() {
        view.backgroundColor = .systemBackground
        
        setupNavBar()
        addCollectionView()
    }
    
    func setupNavBar() {
        title = "Images"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    func addCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func performBatchUpdate(on collectionView: UICollectionView,
                            newURLs: [URL],
                            indexPath: IndexPath) {
        self.imageURLs = newURLs
        
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [indexPath])
        } completion: { _ in
            UIView.animate(withDuration: 0.25) {
                collectionView.layoutIfNeeded()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension ImagesCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier,
            for: indexPath
        )
        guard let imageCell = reuseCell as? ImageCollectionViewCell else { return reuseCell }
        // Clear image — actual load triggered in willDisplay
        imageCell.prepareForReuseState()
        return imageCell
    }
}

extension ImagesCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontalPadding = 20.0 // left 10 + right 10
        let width = collectionView.bounds.width - CGFloat(totalHorizontalPadding)
        let itemSize = CGSize(width: width, height: width) // height == width
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
        else { return }
        
        guard cell.isImageLoaded else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            cell.transform = CGAffineTransform(translationX: collectionView.bounds.width, y: 0)
            cell.alpha = 0.0
        }, completion: { [weak self] _ in
            guard let self else { return }
            
            // Update dataSource
            var updatedURLs = self.imageURLs
            updatedURLs.remove(at: indexPath.item)
            
            // delete item with animation
            self.performBatchUpdate(
                on: collectionView,
                newURLs: updatedURLs,
                indexPath: indexPath
            )
        })
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ImageCollectionViewCell else { return }
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
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.item < imageURLs.count {
            let url = imageURLs[indexPath.item]
            imageLoader.cancelLoad(for: url)
        }
    }
}

