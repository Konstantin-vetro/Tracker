//
//  HabitViewController.swift
//  Tracker
//

import UIKit

final class NewTrackerViewController: UIViewController {
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 30))
        textField.leftViewMode = .always
        textField.placeholder = NSLocalizedString("EnterTracker", comment: "")
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
        label.text = NSLocalizedString("Limit", comment: "")
        label.textColor = .Red
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.textColor = .BlackDay
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SubtitledTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .BackgroundDay
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
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.Red.cgColor
        button.setTitleColor(.Red, for: .normal)
        button.backgroundColor = .BackgroundDay
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(exitView), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal)
        button.setTitleColor(.BackgroundDay, for: .normal)
        button.backgroundColor = .Gray
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
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
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
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
        collectionView.backgroundColor = .BackgroundDay
        collectionView.allowsMultipleSelection = true
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    // MARK: - Properties
    private var daysLabelConstraintToContent = NSLayoutConstraint()
    private var daysLabelConstraintToTextField = NSLayoutConstraint()
    private var labelBetweenTextFieldAndTableContraint = NSLayoutConstraint()
    private var tableViewHeightContraint = NSLayoutConstraint()
    private var collectionViewHeightContraint = NSLayoutConstraint()
    
    var chooseIrregularEvent: Bool = false
    lazy var isEdit: Bool = false
    
    private let namesButton: [String] = [NSLocalizedString("Category", comment: ""),
                                         NSLocalizedString("Schedule", comment: "")]
    
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

    var currentTracker: Tracker?
    var editCategory: String?
    var daysCount: Int?
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupViews()
        updateCollectionViewHeight()
        editTracker()
    }
    // MARK: - Actions
    @objc
    private func createTracker() {
        guard let name = textField.text,
              let category = detailTextCategory,
              let selectedEmojieIndexPath = isSelectedEmoji,
              let selectedColorIndexPath = isSelectedColor
        else { return }
        
        let emojie = emojies[selectedEmojieIndexPath.row]
        let color = colors[selectedColorIndexPath.row]
        let finalShedule: [String]? = chooseIrregularEvent ?  nil : detailTextDays
        
        if isEdit {
            guard let currentTracker = currentTracker else { return }
            let updatedTracker = Tracker(id: currentTracker.id, name: name, color: color, emojie: emojie, shedule: finalShedule)
            onTrackerCreated?(updatedTracker, category)
        } else {
            let newTracker = Tracker(id: UUID(), name: name, color: color, emojie: emojie, shedule: finalShedule)
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
        
        tableViewHeightContraint = tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height)
        collectionViewHeightContraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        daysLabelConstraintToTextField = daysLabel.bottomAnchor.constraint(equalTo: textField.topAnchor,
                                                                           constant: 0)
        // MARK: - Layouts
        [daysLabel, textField, messageLabel, tableView, collectionView, buttonStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        [createButton, cancelButton, contentView, scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.backgroundColor = .BackgroundDay
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            daysLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            daysLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            daysLabelConstraintToTextField,
            
            textField.heightAnchor.constraint(equalToConstant: 75),
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
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -20),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        ])
    }
    // MARK: - Functions
    private func updateCollectionViewHeight() {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
        collectionViewHeightContraint.constant = collectionView.contentSize.height
    }
    
    private func setupCreateButton() {
        guard let isSelectedEmoji = isSelectedEmoji,
              let isSelectedColor = isSelectedColor
        else { return }

        let checkAllFields = textField.hasText
            && detailTextCategory != nil
            && !isSelectedEmoji.isEmpty
            && !isSelectedColor.isEmpty

        if !chooseIrregularEvent {
            if checkAllFields && detailTextDays != nil {
                createButton.backgroundColor = .BlackDay
                createButton.isEnabled = true
            } else {
                createButton.backgroundColor = .Gray
                createButton.isEnabled = false
            }
        } else {
            if checkAllFields {
                createButton.backgroundColor = .BlackDay
                createButton.isEnabled = true
            } else {
                createButton.backgroundColor = .Gray
                createButton.isEnabled = false
            }
        }
    }
    
    private func editTracker() {
        guard let daysTracker = daysCount,
              let currentTracker = currentTracker else { return }
        
        if isEdit {
            daysLabelConstraintToTextField.constant = -40
            
            let daysString = String.localizedStringWithFormat(NSLocalizedString("updateCounterText", comment: ""), daysTracker)
            switch daysTracker % 10 {
            case 1:
                daysLabel.text = "\(daysTracker) " + daysString
            case 2 ... 4:
                daysLabel.text = "\(daysTracker) " + daysString
            default:
                daysLabel.text = "\(daysTracker) " + daysString
            }
            
            textField.text = currentTracker.name
            detailTextCategory = editCategory
            detailTextDays = currentTracker.shedule
            
            if let emojiIndex = emojies.firstIndex(of: currentTracker.emojie) {
                let emojieIndexPath = IndexPath(row: emojiIndex, section: 0)
                collectionView.selectItem(at: emojieIndexPath, animated: false, scrollPosition: [])
                collectionView(collectionView, didSelectItemAt: emojieIndexPath)
            }

            if let colorIndex = colors.firstIndex(where: { UIColor.areAlmostEqual(color1: $0,
                                                                                  color2: currentTracker.color) }) {
                let colorIndexPath = IndexPath(row: colorIndex, section: 1)
                collectionView.selectItem(at: colorIndexPath, animated: false, scrollPosition: [])
                collectionView(collectionView, didSelectItemAt: colorIndexPath)
            }
            
            createButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        } else {
            daysLabelConstraintToTextField.constant = 0
        }
    }
}
// MARK: - UITextFieldDelegate
extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count > 38 {
            messageLabel.isHidden = false
            labelBetweenTextFieldAndTableContraint.constant = -35
        } else {
            messageLabel.isHidden = true
            labelBetweenTextFieldAndTableContraint.constant = 0
        }
        setupCreateButton()
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
                detailTextLabel.text = NSLocalizedString("EveryDay", comment: "")
            } else {
                let sortedDays = detailTextDays?.sorted { first, second in
                    let orderedDays = [
                        NSLocalizedString("shortMonday", comment: ""),
                        NSLocalizedString("shortTuesday", comment: ""),
                        NSLocalizedString("shortWednesday", comment: ""),
                        NSLocalizedString("shortThursday", comment: ""),
                        NSLocalizedString("shortFriday", comment: ""),
                        NSLocalizedString("shortSaturday", comment: ""),
                        NSLocalizedString("shortSunday", comment: ""),
                    ]
                    return orderedDays.firstIndex(of: first) ?? 0 < orderedDays.firstIndex(of: second) ?? 0
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
            categoriesViewController.title = NSLocalizedString("Category", comment: "")
            
            let navigationController = UINavigationController(rootViewController: categoriesViewController)
            navigationController.navigationBar.barTintColor = .BackgroundDay
            navigationController.navigationBar.shadowImage = UIImage()
            present(navigationController, animated: true)
        } else if indexPath.row == 1 {
            let sheduleViewController = SheduleViewController()
            sheduleViewController.delegate = self
            sheduleViewController.title = NSLocalizedString("Schedule", comment: "")
            
            let navigationController = UINavigationController(rootViewController: sheduleViewController)
            navigationController.navigationBar.barTintColor = .BackgroundDay
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
            
            cell.colorView.backgroundColor = colors[indexPath.row]
            cell.configure(isSelected: cell.isSelected, for: colors, at: indexPath)
            
            return cell
        }
        return UICollectionViewCell()
    }
}
// MARK: - UICollectionViewDelegate
extension NewTrackerViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let selectedCell = isSelectedEmoji,
               let cell = collectionView.cellForItem(at: selectedCell) as? EmojiCollectionViewCell {
                cell.backgroundColor = .clear
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
                cell.backgroundColor = .LightGray
            }
            
            isSelectedEmoji = indexPath
            setupCreateButton()
        } else if indexPath.section == 1 {
            if let selectedCell = isSelectedColor,
               let cell = collectionView.cellForItem(at: selectedCell) as? ColorsCollectionViewCell {
                cell.configure(isSelected: false, at: selectedCell)
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorsCollectionViewCell {
                cell.configure(isSelected: true, for: colors, at: indexPath)
            }
            
            isSelectedColor = indexPath
            setupCreateButton()
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
            view.titleLabel.text = NSLocalizedString("Color", comment: "")
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
        setupCreateButton()
    }
    
    func addDetailDays(_ days: [String]) {
        detailTextDays = days
        tableView.reloadData()
        setupCreateButton()
    }
}
