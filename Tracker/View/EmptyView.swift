//
//  EmptyCategoryViewController.swift
//  Tracker
//

import UIKit

final class EmptyView: UIView {
    private lazy var placeholderImage =  UIImageView()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    init(frame: CGRect, useImage: Bool? = nil, text: String? = nil, uiImage: UIImage? = nil) {
        super.init(frame: frame)
        guard let imageCollection = UIImage(named: "placeholderImage"),
              let imageFoundTrackers = UIImage(named: "noFound") else { return }
        
        placeholderImage.image = useImage ?? false ? imageCollection : imageFoundTrackers
        let emptyCollection = NSLocalizedString("EmptyCollection", comment: "")
        let emptyFound = NSLocalizedString("EmptyFound", comment: "")
        if text != nil {
            placeholderImage.image = uiImage
            textLabel.text = text
        } else {
            textLabel.text = useImage ?? false ? emptyCollection : emptyFound
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
        
        backgroundColor = .BackgroundDay
        
        NSLayoutConstraint.activate([
            placeholderImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            textLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant:  8),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
