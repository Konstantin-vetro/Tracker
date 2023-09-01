//
//  EmptyCategoryViewController.swift
//  Tracker
//

import UIKit

final class EmptyView: UIView {
    private lazy var placeholderImage: UIImageView = {
        let image = UIImage(named: "placeholderImage")
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    init(frame: CGRect, useImage: Bool, text: String? = nil) {
        super.init(frame: frame)
        guard let imageCollection = UIImage(named: "placeholderImage") else { return }
        guard let imageFoundTrackers = UIImage(named: "noFound") else { return }
        
        self.placeholderImage.image = useImage ? imageCollection : imageFoundTrackers
        if text != nil {
            self.textLabel.text = text
        } else {
            self.textLabel.text = useImage ? "Что будем отслеживать?" : "Ничего не найдено"
        }
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layouts
    private func setupViews() {
        [placeholderImage, textLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        backgroundColor = .white
        
        NSLayoutConstraint.activate([
            placeholderImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            textLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant:  8),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
