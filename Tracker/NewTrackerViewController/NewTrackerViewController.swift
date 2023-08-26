//
//  HabitViewController.swift
//  Tracker
//

import UIKit

protocol HabitDelegate: AnyObject {
    func addDetailCategory(_ text: String)
    func addDetailDays(_ days: [String])
}

final class NewTrackerViewController: UIViewController {
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 30))
        textField.leftViewMode = .always
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .defaultColor
        textField.layer.cornerRadius = 10
        textField.clearButtonMode = .whileEditing
        textField.clipsToBounds = true
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .Red
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 200),
                                    style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SubtitledTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.Red.cgColor
        button.setTitleColor(.Red, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(exitView), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .Gray
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(createNewTracker), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        return stackView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .white
        return contentView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(EmojiCollectionViewCell.self,
                                forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collectionView.register(ColorsCollectionViewCell.self,
                                forCellWithReuseIdentifier: ColorsCollectionViewCell.identifier)
        collectionView.register(HeaderViewCell.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        collectionView.backgroundColor = .white
        collectionView.allowsMultipleSelection = true
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    // MARK: - Properties
    private var labelBetweenTextFieldAndTableContraint: NSLayoutConstraint!
    
    private var collectionViewHeightContraint: NSLayoutConstraint!
    
    var chooseIrregularEvent: Bool = false
    
    private let namesButton: [String] = ["Категория", "Расписание"]
    
    private var detailTextCategory: String?
    
    private var detailTextDays: [String]?
    
    private let emojies = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    private let colors: [UIColor] = UIColor.colorSelection
    
    private var isSelectedEmoji: IndexPath?
    
    private var isSelectedColor: IndexPath?
    
    var onTrackerCreated: ((_ tracker: Tracker, _ titleCategory: String?) -> Void)?
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chooseIrregularEvent {
            textField.placeholder = "Введите название события"
        }
        
        setupViews()
        updateCollectionViewHeight()
    }
    // MARK: - Actions
    @objc
    private func createNewTracker() {
        guard let text = textField.text, let category = detailTextCategory else { return }
        guard let selectedEmojieIndexPath = isSelectedEmoji,
              let selectedColorIndexPath = isSelectedColor else { return }
        let emojie = emojies[selectedEmojieIndexPath.row]
        let color = colors[selectedColorIndexPath.row]
        
        if chooseIrregularEvent {
            let newTracker = Tracker(id: UUID(), name: text, color: color, emojie: emojie, shedule: nil)
            onTrackerCreated?(newTracker, category)
        } else {
            guard let shedule = detailTextDays else { return }
            let newTracker = Tracker(id: UUID(), name: text, color: color, emojie: emojie, shedule: shedule)
            onTrackerCreated?(newTracker, category)
        }
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    @objc
    private func exitView() {
        dismiss(animated: true)
    }
    
    // MARK: - SetupViews
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        labelBetweenTextFieldAndTableContraint = NSLayoutConstraint(
            item: textField,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: tableView,
            attribute: .top,
            multiplier: 1,
            constant: 0
        )
        
        let tableViewHeightContraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightContraint.constant = tableView.contentSize.height
        collectionViewHeightContraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        
        // MARK: - Layouts
        [textField, messageLabel, tableView, collectionView, buttonStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        [createButton, cancelButton, contentView, scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            labelBetweenTextFieldAndTableContraint,
            
            messageLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            messageLabel.centerXAnchor.constraint(equalTo: textField.centerXAnchor),
            
            tableViewHeightContraint,
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            collectionViewHeightContraint,
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -20),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        ])
    }
    
    private func updateCollectionViewHeight() {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
        collectionViewHeightContraint.constant = collectionView.contentSize.height
    }
}
// MARK: - UITextFieldDelegate
extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count > 38 {
            messageLabel.isHidden = false
            labelBetweenTextFieldAndTableContraint?.constant = -35
        } else {
            messageLabel.isHidden = true
            labelBetweenTextFieldAndTableContraint?.constant = 0
        }
        view.layoutIfNeeded()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
// MARK: - UITableViewDataSource
extension NewTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !chooseIrregularEvent {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = namesButton[indexPath.row]
        cell.backgroundColor = .defaultColor
        cell.accessoryType = .disclosureIndicator
        
        guard let detailTextLabel = cell.detailTextLabel else { return cell }
        detailTextLabel.font = UIFont.systemFont(ofSize: 17)
        detailTextLabel.textColor = .Gray
        
        switch indexPath.row {
        case 0:
            detailTextLabel.text = detailTextCategory
        case 1:
            if detailTextDays?.count == 7 {
                detailTextLabel.text = "Каждый день"
            } else {
                let sortedDays = detailTextDays?.sorted { first, second in
                    let orderedDays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
                    return orderedDays.firstIndex(of: first)! < orderedDays.firstIndex(of: second)!
                }
                let days = sortedDays?.joined(separator: ", ")
                detailTextLabel.text = days
            }
        default:
            break
        }
        
        return cell
    }
}
// MARK: - UITableViewDelegate
extension NewTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let categoriesViewController = CategoriesViewController()
            categoriesViewController.delegate = self
            categoriesViewController.title = "Категория"
            
            let navigationController = UINavigationController(rootViewController: categoriesViewController)
            navigationController.navigationBar.barTintColor = .white
            navigationController.navigationBar.shadowImage = UIImage()
            present(navigationController, animated: true)
        } else if indexPath.row == 1 {
            let sheduleViewController = SheduleViewController()
            sheduleViewController.delegate = self
            sheduleViewController.title = "Расписание"
            
            let navigationController = UINavigationController(rootViewController: sheduleViewController)
            navigationController.navigationBar.barTintColor = .white
            navigationController.navigationBar.shadowImage = UIImage()
            present(navigationController, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension NewTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? emojies.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCollectionViewCell.identifier,
                for: indexPath
            ) as? EmojiCollectionViewCell else { return UICollectionViewCell()}
            
            cell.titleLabel.text = emojies[indexPath.row]
            cell.backgroundColor = cell.isSelected ? .LightGray : .clear
           
            return cell
        } else if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorsCollectionViewCell.identifier,
                for: indexPath
            ) as? ColorsCollectionViewCell else { return UICollectionViewCell()}
            
            cell.sizeToFit()
            cell.colorView.backgroundColor = colors[indexPath.row]
            
            return cell
        }
        return UICollectionViewCell()
    }
}
// MARK: - UICollectionViewDelegate
extension NewTrackerViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let selectedCell = isSelectedEmoji {
                let cell = collectionView.cellForItem(at: selectedCell)
                cell?.backgroundColor = .clear
            }
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.cornerRadius = 10
            cell?.backgroundColor = .LightGray
            isSelectedEmoji = indexPath
        } else if indexPath.section == 1 {
            if let selectedCell = isSelectedColor {
                let cell = collectionView.cellForItem(at: selectedCell)
                cell?.layer.borderWidth = 0
                cell?.layer.borderColor = .none
            }
            let cell = collectionView.cellForItem(at: indexPath)
            let transparentColors = colors.map { $0.withAlphaComponent(0.3) }
            let bordedColor = transparentColors[indexPath.row]
            
            cell?.layer.cornerRadius = 10
            cell?.layer.borderWidth = 3
            cell?.layer.borderColor = bordedColor.cgColor
            isSelectedColor = indexPath
            createButton.backgroundColor = .BlackDay
            createButton.isEnabled = true
        }
    }
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        
        if indexPath.section == 0 {
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? HeaderViewCell else { return UICollectionReusableView()}
            view.titleLabel.text = "Emoji"
            return view
        } else {
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? HeaderViewCell else { return UICollectionReusableView()}
            view.titleLabel.text = "Цвет"
            return view
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        )
        
        return headerView.systemLayoutSizeFitting(CGSize(
            width: collectionView.frame.width,
            height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}
// MARK: - HabitDelegate
extension NewTrackerViewController: HabitDelegate {
    func addDetailCategory(_ text: String) {
        detailTextCategory = text
        tableView.reloadData()
    }
    
    func addDetailDays(_ days: [String]) {
        detailTextDays = days
        tableView.reloadData()
    }
}
