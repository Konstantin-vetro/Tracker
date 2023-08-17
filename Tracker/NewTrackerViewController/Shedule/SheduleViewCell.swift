//
//  ColorsCollectionViewCell.swift
//  Tracker
//

import UIKit

protocol SheduleViewCellDelegate: AnyObject {
    func didToogleSwitch(for day: String, isOn: Bool)
}

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
        case "Понедельник":
            return "Пн"
        case "Вторник":
            return "Вт"
        case "Среда":
            return "Ср"
        case "Четверг":
            return "Чт"
        case "Пятница":
            return "Пт"
        case "Суббота":
            return "Сб"
        case "Воскресенье":
            return "Вс"
        default:
            return ""
        }
    }
}
