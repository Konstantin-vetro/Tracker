//
//  LetterCollectionViewCell.swift
//  Tracker
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    static let identifier = "cell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 35)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 10
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate(
            [
                titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
