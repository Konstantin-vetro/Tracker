//
//  ColorsCollectionViewCell.swift
//  Tracker
//

import UIKit

final class SheduleViewCell: UITableViewCell {
    static let identifier = "sheduleCell"
    
    weak var delegateCell: SheduleViewCellDelegate?
    
    private lazy var switchDay: UISwitch = {
        let switchDay = UISwitch()
        switchDay.translatesAutoresizingMaskIntoConstraints = false
        switchDay.onTintColor = .blue
        switchDay.addTarget(self, action: #selector(switchTapped), for: .valueChanged)
        return switchDay
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(switchDay)
        
        NSLayoutConstraint.activate(
            [
                switchDay.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                switchDay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            ]
        )
    }
    // MARK: - Action
    @objc
    private func switchTapped(_ sender: UISwitch) {
        if let daysOfWeek = textLabel?.text {
            let shortDay = shortDays(for: daysOfWeek)
            delegateCell?.didToogleSwitch(for: shortDay, isOn: sender.isOn)
        }
    }
    // MARK: - Shorten the Days
    private func shortDays(for day: String) -> String {
        switch day {
        case NSLocalizedString("Monday", comment: ""):
            return NSLocalizedString("shortMonday", comment: "")
        case NSLocalizedString("Tuesday", comment: ""):
            return NSLocalizedString("shortTuesday", comment: "")
        case NSLocalizedString("Wednesday", comment: ""):
            return NSLocalizedString("shortWednesday", comment: "")
        case NSLocalizedString("Thursday", comment: ""):
            return NSLocalizedString("shortThursday", comment: "")
        case NSLocalizedString("Friday", comment: ""):
            return NSLocalizedString("shortFriday", comment: "")
        case NSLocalizedString("Saturday", comment: ""):
            return NSLocalizedString("shortSaturday", comment: "")
        case NSLocalizedString("Sunday", comment: ""):
            return NSLocalizedString("shortSunday", comment: "")
        default:
            return ""
        }
    }
}
