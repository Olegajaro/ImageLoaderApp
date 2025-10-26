//
//  ImageCollectionViewCell.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 25.10.2025.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: ImageCollectionViewCell.self)

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    private let spinner: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods
extension ImageCollectionViewCell {
    func prepareForReuseState() {
        imageView.image = nil
        spinner.stopAnimating()
    }

    func showLoading() {
        spinner.startAnimating()
    }

    func configure(with image: UIImage) {
        spinner.stopAnimating()
        imageView.image = image
    }

    func configureWithPlaceholder() {
        spinner.stopAnimating()
        // simple placeholder
        imageView.image = UIImage(systemName: "exclamationmark.triangle")
        imageView.tintColor = .systemOrange
    }
}

// MARK: - Setup Views
private extension ImageCollectionViewCell {
    func setupViews() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true

        contentView.addSubview(imageView)
        contentView.addSubview(spinner)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
