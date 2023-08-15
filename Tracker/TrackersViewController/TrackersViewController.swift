//
//  ViewController.swift
//  Tracker
//

import UIKit

protocol FilterDelegate: AnyObject {
    func showAllTrackers()
}

protocol TrackerViewControllerDelegate: AnyObject {
    func createTracker(_ tracker: Tracker?, titleCategory: String?)
}

class TrackersViewController: UIViewController, TrackerViewControllerDelegate {
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.tintColor = .black
        let localeID = Locale.preferredLanguages.first
        picker.locale = Locale(identifier: localeID ?? "en_EN")
        picker.addTarget(self, action: #selector(datePickerValueChanges), for: .valueChanged)
        return picker
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.delegate = self
        textField.backgroundColor = .defaultColor
        textField.returnKeyType = .done
        textField.placeholder = "Поиск"
        return textField
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackerCell.self,
                                forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(HeaderViewCell.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        collectionView.backgroundColor = .white
        collectionView.allowsMultipleSelection = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Фильтры", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .Blue
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addFilter), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = []//mockDataTrackers
    
    var currentDate: Date { return datePicker.date }
    
    private var newTracker: Tracker?
    
    private var filteredCategoriesByDate: [TrackerCategory] = []
    
    private var completedTrackers: Set<TrackerRecord> = []
    
    private var visibleCategories: [TrackerCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visibleCategories = categories
        setupNavigationBar()
        setupView()
        updateCollectionView()
    }
    
    // MARK: - Layouts
    private func setupView() {
        [searchTextField, collectionView, filterButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate(
            [
                searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                
                collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                
                filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                filterButton.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -16),
                filterButton.heightAnchor.constraint(equalToConstant: 50),
                filterButton.widthAnchor.constraint(equalToConstant: 114),
            ]
        )
    }
    // MARK: - Actions
    @objc
    private func addTracker() {
        let trackersTypeViewController = TrackersTypeViewController()
        trackersTypeViewController.title = "Создание трекера"
        trackersTypeViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: trackersTypeViewController)
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationBar.shadowImage = UIImage()
        present(navigationController, animated: true)
    }
    
    @objc
    private func addFilter() {
        let filterViewController = FilterViewController()
        filterViewController.title = "Фильтры"
        filterViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: filterViewController)
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationBar.shadowImage = UIImage()
        present(navigationController, animated: true)
    }
    
    @objc
    private func datePickerValueChanges(_ sender: UIDatePicker) {
        let weekDay = sender.calendar.component(.weekday, from: sender.date)
        var day = ""
        
        switch weekDay {
        case 1:
            day = "Вс"
        case 2:
            day = "Пн"
        case 3:
            day = "Вт"
        case 4:
            day = "Ср"
        case 5:
            day = "Чт"
        case 6:
            day = "Пт"
        case 7:
            day = "Сб"
        default:
            break
        }
        
        filteredCategoriesByDate = categories
        for category in categories {
            var filterTrackers: [Tracker] = []
            for tracker in category.trackers {
                if let schedule = tracker.shedule {
                    if schedule.contains(where: { $0 == day }) {
                        filterTrackers.append(tracker)
                    }
                }
            }
            
            let newCategory = TrackerCategory(title: category.title, trackers: filterTrackers)
            if newCategory.title == category.title {
                let index = categories.firstIndex(where: { $0.title == newCategory.title })!
                categories[index] = newCategory
            }
        }
        
        for category in categories {
            if category.trackers.isEmpty {
                let index = categories.firstIndex(where: { $0.trackers.isEmpty })!
                categories.remove(at: index)
            }
        }
        
        updateCollectionView()
        visibleCategories = categories
        dismiss(animated: true) {
            self.categories = self.filteredCategoriesByDate
        }
    }
    // MARK: - Settings
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTracker))
        addButton.tintColor = .black
        let date = UIBarButtonItem(customView: datePicker)
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = date
    }
    
    private func updateCollectionView() {
        if categories.isEmpty {
            let emptyView = EmptyView(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: view.bounds.width,
                                                    height: view.bounds.height),
                                      text: "Что будем отслеживать?")
            collectionView.backgroundView = emptyView
            filterButton.isHidden = true
        } else {
            collectionView.backgroundView = nil
            filterButton.isHidden = false
        }
        
        collectionView.reloadData()
    }
    
    func createTracker(_ tracker: Tracker?, titleCategory: String?) {
        guard let newTracker = tracker, let newTitleCategory = titleCategory else { return }
        let newCategory = TrackerCategory(title: newTitleCategory, trackers: [newTracker])
        if categories.contains(where: { $0.title == newCategory.title}) {
            let index = categories.firstIndex { $0.title == newCategory.title }!
            let oldCategory = categories[index]
            let updatedTrackers = oldCategory.trackers + newCategory.trackers
            let updatedTrackerCategory = TrackerCategory(title: newCategory.title, trackers: updatedTrackers)
            categories[index] = updatedTrackerCategory
        } else {
            categories.append(newCategory)
        }
        
        visibleCategories = categories
        updateCollectionView()
    }
    // MARK: - ContextMenuForItemAt
    private func makeContextMenuForItemAt(indexPath: IndexPath, collectionView: UICollectionView) -> UIMenu {
        let fixAction = UIAction(title: "Закрепить") { _ in }
        let editAction = UIAction(title: "Редактировать") { _ in }
        let deleteAction = makeDeleteAction(indexPath: indexPath, collectionView: collectionView)
        return UIMenu(title: "", children: [fixAction, editAction, deleteAction])
    }

    private func makeDeleteAction(indexPath: IndexPath, collectionView: UICollectionView) -> UIAction {
        return UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
            guard let self = self else { return }
            let alert = UIAlertController(title: "", message: "Уверены что хотите удалить трекер?", preferredStyle: .actionSheet)
            let delete = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                self?.deleteTracker(at: indexPath, in: collectionView)
            }
            
            let cancel = UIAlertAction(title: "Отменить", style: .cancel)
            alert.addAction(delete)
            alert.addAction(cancel)
            
            self.present(alert, animated: true)
        }
    }

    private func deleteTracker(at indexPath: IndexPath, in collectionView: UICollectionView) {
        let category = self.visibleCategories[indexPath.section]

        var updatedTrackers = category.trackers
        updatedTrackers.remove(at: indexPath.row)
        let updatedCategory = TrackerCategory(title: category.title, trackers: updatedTrackers)

        if updatedCategory.trackers.isEmpty {
            self.visibleCategories.remove(at: indexPath.section)
            collectionView.performBatchUpdates({
                collectionView.deleteSections(IndexSet(integer: indexPath.section))
            }, completion: { _ in self.categories = self.visibleCategories })
        } else {
            self.visibleCategories[indexPath.section] = updatedCategory
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [indexPath])
            }, completion: { _ in self.categories = self.visibleCategories })
        }
        self.categories = self.visibleCategories
        self.updateCollectionView()
    }
}
// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell()}
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let daysCount = completedTrackers.filter { $0.id == tracker.id }.count
        let isToday = completedTrackers.contains {
            $0.id == tracker.id &&
            areDatesEqualIgnoringTime(date1: $0.date, date2: currentDate
            ) } ? true : false
        
        cell.setupCell(tracker: tracker)
        cell.completeTracker(days: daysCount, isToday: isToday)
        cell.delegate = self
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? HeaderViewCell else { return UICollectionReusableView()}
        view.titleLabel.text = visibleCategories[indexPath.section].title
        return view
    }
}
// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let menu = makeContextMenuForItemAt(indexPath: indexPath, collectionView: collectionView)
        return UIContextMenuConfiguration(actionProvider: { _ in menu })
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - 9
        return CGSize(width: availableWidth / 2 , height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
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
// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func plusButtonTapped(on cell: TrackerCell) {
        let indexPath: IndexPath = collectionView.indexPath(for: cell) ?? IndexPath()
        let id = visibleCategories[indexPath.section].trackers[indexPath.row].id
        var daysCount = completedTrackers.filter { $0.id == id }.count
        let isToday = completedTrackers.contains(where: { $0.id == id && areDatesEqualIgnoringTime(date1: $0.date, date2: currentDate) })
        if !isToday {
            completedTrackers.insert(TrackerRecord(id: id, date: currentDate))
            daysCount += 1
        } else {
            completedTrackers.remove(TrackerRecord(id: id, date: currentDate))
            daysCount -= 1
        }
        cell.completeTracker(days: daysCount, isToday: !isToday)
    }
    
    private func areDatesEqualIgnoringTime(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedSame
    }
}
// MARK: - UITextFieldDelegate
extension TrackersViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        let updatedString = nsString?.replacingCharacters(in: range, with: string)
        
        guard let searchText = updatedString, !searchText.isEmpty else {
            visibleCategories = categories
            updateCollectionView()
            return true
        }
        filterCategories(with: searchText)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        visibleCategories = categories
        updateCollectionView()
        return true
    }
    
    private func filterCategories(with searchText: String) {
        visibleCategories = categories.map { category -> TrackerCategory in
            let filteredTrackers = category.trackers.filter { tracker -> Bool in
                return tracker.name.lowercased().contains(searchText.lowercased())
            }

            let filteredCategory = TrackerCategory(title: category.title, trackers: filteredTrackers)

            return filteredCategory
        }.filter { $0.trackers.count > 0}

        updateCollectionView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
// MARK: - FilterDelegate
extension TrackersViewController: FilterDelegate {
    func showAllTrackers() {
        visibleCategories = categories
        updateCollectionView()
    }
}
