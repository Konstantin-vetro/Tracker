//
//  SupplementaryView.swift
//  Tracker
//

import UIKit

final class HeaderViewCell: UICollectionReusableView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    private var heightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 54)
        heightConstraint.priority = .defaultHigh
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate(
            [
                heightConstraint,
                titleLabel.topAnchor.constraint(equalTo: topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
