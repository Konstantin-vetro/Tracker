//
//  ColorsCollectionViewCell.swift
//  Tracker
//

import UIKit

final class ColorsCollectionViewCell: UICollectionViewCell {
    static let identifier = "colorCell"
    
    let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate(
            [
                colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                colorView.heightAnchor.constraint(equalToConstant: 40),
                colorView.widthAnchor.constraint(equalToConstant: 40)
            ]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(isSelected: Bool, for colors: [UIColor]? = nil, at indexPath: IndexPath) {
        if isSelected {
            let bordedColor = colors?[indexPath.row].withAlphaComponent(0.3)
            
            layer.borderWidth = 3
            layer.borderColor = bordedColor?.cgColor
        } else {
            layer.borderWidth = 0
            layer.borderColor = .none
        }
    }
}
