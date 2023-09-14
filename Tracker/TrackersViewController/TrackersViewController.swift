//
//  ViewController.swift
//  Tracker
//

import UIKit

class TrackersViewController: UIViewController {
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    
    var currentDate: Date { return datePicker.date }
    
    private var completedTrackers: Set<TrackerRecord> = []
    private var isCompleteSelectedTracker: [UUID: Bool] = [:]
    private var fixedTrackers: [Tracker] = []
    private var fixedCategory: TrackerCategory?
    
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private let analyticsService: AnalyticsServiceProtocol = AnalyticsService()
    // MARK: - UI
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.tintColor = .black
        let localeID = Locale.preferredLanguages.first
        picker.backgroundColor = .white
        picker.locale = Locale(identifier: localeID ?? "en_EN")
        picker.addTarget(self, action: #selector(datePickerValueChanges), for: .valueChanged)
        return picker
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.delegate = self
        textField.backgroundColor = .defaultColor
        textField.returnKeyType = .done
        textField.placeholder = NSLocalizedString("Search", comment: "")
        return textField
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackerCell.self,
                                forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(HeaderViewCell.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        collectionView.backgroundColor = .BackgroundDay
        collectionView.allowsMultipleSelection = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Filters", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .Blue
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addFilter), for: .touchUpInside)
        return button
    }()
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = trackerCategoryStore.categories
        completedTrackers = trackerRecordStore.records
        hideKeyboardWhenTappedAround()
        setupNavigationBar()
        setupView()
        loadFixedTrackers()
        showVisibleCategories()
        isCompletedTracker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.openScreenReport(screen: .main)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.closeScreenReport(screen: .main)
    }
    // MARK: - Actions
    @objc
    private func addTracker() {
        analyticsService.addTrackReport()
        let trackersTypeViewController = TrackersTypeViewController()
        trackersTypeViewController.title = NSLocalizedString("CreateTracker", comment: "")
        trackersTypeViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: trackersTypeViewController)
        navigationController.navigationBar.barTintColor = .BackgroundDay
        navigationController.navigationBar.shadowImage = UIImage()
        present(navigationController, animated: true)
    }
    
    @objc
    private func addFilter() {
        analyticsService.addFilterReport()
        let filterViewController = FilterViewController()
        filterViewController.title = NSLocalizedString("Filters", comment: "")
        filterViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: filterViewController)
        navigationController.navigationBar.barTintColor = .BackgroundDay
        navigationController.navigationBar.shadowImage = UIImage()
        present(navigationController, animated: true)
    }
    
    @objc
    private func datePickerValueChanges(_ sender: UIDatePicker) {
        if let searchText = searchTextField.text, !searchText.isEmpty {
            filterCategories(with: searchText)
        } else {
            showVisibleCategories()
        }
        isCompletedTracker()
        dismiss(animated: true)
    }
    // MARK: - Layouts
    private func setupView() {
        [searchTextField, collectionView, filterButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        view.backgroundColor = .BackgroundDay
        
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
                filterButton.widthAnchor.constraint(equalToConstant: 114)
            ]
        )
    }
    // MARK: - Settings
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTracker))
        addButton.tintColor = .BlackDay
        let date = UIBarButtonItem(customView: datePicker)
        navigationItem.title = NSLocalizedString("Trackers", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = date
    }
    
    private func showVisibleCategories() {
        categories = trackerCategoryStore.categories.sorted {
            $0.title.lowercased() < $1.title.lowercased()
        }
        
        completedTrackers = trackerRecordStore.records
        
        let fixed = NSLocalizedString("Fixed", comment: "")
        fixedCategory = TrackerCategory(title: fixed, trackers: fixedTrackers)
        
        visibleCategories = categories.map { category -> TrackerCategory in
            let filteredTrackers = category.trackers.filter { tracker -> Bool in
                let isTrackerNotFixed = !fixedTrackers.contains(where: {$0.id == tracker.id} )
                
                if let shedule = tracker.shedule, !shedule.isEmpty {
                    return isTrackerNotFixed && shedule.contains { $0 == getADay() }
                } else {
                    return isTrackerNotFixed
                }
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        visibleCategories = visibleCategories.filter { !$0.trackers.isEmpty }
        
        if let fixedCategory = fixedCategory, !fixedCategory.trackers.isEmpty {
            visibleCategories.insert(fixedCategory, at: 0)
        }
        
        showBackgroundView(forCollection: true)
    }
    
    private func getADay() -> String {
        let weekDay = Calendar.current.component(.weekday, from: currentDate)
        var day = ""
        
        switch weekDay {
        case 1: day = "Вс"
        case 2: day = "Пн"
        case 3: day = "Вт"
        case 4: day = "Ср"
        case 5: day = "Чт"
        case 6: day = "Пт"
        case 7: day = "Сб"
        default: break
        }
        return day
    }
    
    private func isCompletedTracker() {
        visibleCategories.forEach { category in
            category.trackers.forEach { tracker in
                let isCompletedToday = completedTrackers.contains { recordTracker in
                    recordTracker.id == tracker.id && areDatesEqualIgnoringTime(date1: recordTracker.date, date2: currentDate)
                }
                isCompleteSelectedTracker[tracker.id] = isCompletedToday
            }
        }
    }
    
    private func saveFixedTrackers() {
        let fixedTrackerIDs = fixedTrackers.map { $0.id.uuidString }
        UserDefaults.standard.set(fixedTrackerIDs, forKey: "FixedTrackers")
    }
    
    private func loadFixedTrackers() {
        guard let savedFixedTrackerIDs = UserDefaults.standard.array(forKey: "FixedTrackers") as? [String] else { return }
        let savedFixedTrackerUUIDs = savedFixedTrackerIDs.compactMap { UUID(uuidString: $0) }
        
        fixedTrackers = categories
            .flatMap { $0.trackers }
            .filter { savedFixedTrackerUUIDs.contains($0.id) }
    }
    
    private func showBackgroundView(forCollection: Bool) {
        if visibleCategories.isEmpty {
            let emptyView = EmptyView(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: view.bounds.width,
                                                    height: view.bounds.height),
                                      useImage: forCollection)
            collectionView.backgroundView = emptyView
            filterButton.isHidden = true
        } else {
            collectionView.backgroundView = nil
            filterButton.isHidden = false
        }
        
        collectionView.reloadData()
    }
    // MARK: - Context Menu
    private func makeContextMenuForItemAt(indexPath: IndexPath, collectionView: UICollectionView) -> UIMenu {
        let isFixed = isTrackerFixed(at: indexPath)
        let fixAction = makeFixAction(indexPath: indexPath, isFixed: isFixed)
        let editAction = makeEditAction(indexPath: indexPath)
        let deleteAction = makeDeleteAction(indexPath: indexPath, collectionView: collectionView)
        return UIMenu(title: "", children: [fixAction, editAction, deleteAction])
    }
    // MARK: - Fixed
    private func isTrackerFixed(at indexPath: IndexPath) -> Bool {
        let traker = visibleCategories[indexPath.section].trackers[indexPath.row]
        return fixedTrackers.contains { $0.id == traker.id }
    }
    
    private func makeFixAction(indexPath: IndexPath, isFixed: Bool) -> UIAction {
        let pin = NSLocalizedString("Pin", comment: "")
        let unPin = NSLocalizedString("Unpin", comment: "")
        let fixTitle = isFixed ? unPin : pin
        return UIAction(title: fixTitle) { [weak self] _ in
            guard let self = self else { return }
            self.fixTracker(indexPath: indexPath, isFixed: isFixed)
        }
    }
    
    private func fixTracker(indexPath: IndexPath, isFixed: Bool) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        if isFixed {
            if let index = fixedTrackers.firstIndex(where: { $0.id == tracker.id }) {
                fixedTrackers.remove(at: index)
            }
        } else {
            fixedTrackers.append(tracker)
        }
        
        saveFixedTrackers()
        showVisibleCategories()
    }
    // MARK: - Edit
    private func makeEditAction(indexPath: IndexPath) -> UIAction {
        return UIAction(title: NSLocalizedString("Edit", comment: "")) { [weak self] _ in
            guard let self = self else { return }
            self.analyticsService.editTrackReport()
            self.editTracker(at: indexPath)
        }
    }
    
    private func editTracker(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let category = visibleCategories[indexPath.section].title
        let daysCount = completedTrackers.filter { $0.id == tracker.id }.count
        
        let editViewController = NewTrackerViewController()
        
        if tracker.shedule?.isEmpty == true {
            let editEvent = NSLocalizedString("EditEvent", comment: "")
            editViewController.title = editEvent
            editViewController.chooseIrregularEvent = true
        } else {
            let editHabit = NSLocalizedString("EditHabit", comment: "")
            editViewController.title = editHabit
        }
        
        editViewController.isEdit = true
        editViewController.currentTracker = tracker
        editViewController.editCategory = category
        editViewController.daysCount = daysCount
        editViewController.onTrackerCreated = { [weak self] tracker, category in
            guard let self = self else { return }
            self.createTracker(tracker, category: category)
        }
        
        let navigationController = UINavigationController(rootViewController: editViewController)
        navigationController.navigationBar.barTintColor = .BackgroundDay
        navigationController.navigationBar.shadowImage = UIImage()
        present(navigationController, animated: true)
    }
    // MARK: - Delete
    private func makeDeleteAction(indexPath: IndexPath, collectionView: UICollectionView) -> UIAction {
        let confirmMessage = NSLocalizedString("ConfirmTracker", comment: "")
        return UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.analyticsService.deleteTrackReport()
            let alert = UIAlertController(title: "", message: confirmMessage, preferredStyle: .actionSheet)
            let delete = UIAlertAction(title: NSLocalizedString("Delete", comment: ""),
                                       style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.deleteTracker(at: indexPath, in: collectionView)
            }
            
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
            alert.addAction(delete)
            alert.addAction(cancel)
            
            self.present(alert, animated: true)
        }
    }
    
    private func deleteTracker(at indexPath: IndexPath, in collectionView: UICollectionView) {
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let recordID = categories[indexPath.section].trackers[indexPath.row].id
        
        do {
            try trackerStore.deleteTracker(with: tracker.id)
        } catch {
            print("Failed to delete tracker from CoreData: \(error)")
        }
        
        let recordToDelete = completedTrackers.filter { $0.id == recordID }
        for record in recordToDelete {
            do {
                try trackerRecordStore.deleteRecord(record)
            } catch {
                print("Failed to delete record from CoreData: \(error)")
            }
            completedTrackers.remove(record)
        }
        
        let category = visibleCategories[indexPath.section]
        
        var updatedTrackers = category.trackers
        updatedTrackers.remove(at: indexPath.row)
        let updatedCategory = TrackerCategory(title: category.title, trackers: updatedTrackers)
        
        if updatedCategory.trackers.isEmpty {
            do {
                try trackerCategoryStore.deleteCategory(with: category.title)
            } catch {
                print("Failed to delete category from CoreData: \(error)")
            }
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
        categories = visibleCategories
        showBackgroundView(forCollection: true)
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
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else { return UICollectionViewCell()}
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let daysCount = completedTrackers.filter { $0.id == tracker.id }.count
        
        let cellCompleted = isCompleteSelectedTracker[tracker.id] ?? false
        
        cell.setup(tracker: tracker)
        cell.updateRecord(days: daysCount, isCompleted: cellCompleted)
        cell.delegate = self
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header", for: indexPath
        ) as? HeaderViewCell else { return UICollectionReusableView()}
        
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
            height: UIView.layoutFittingExpandedSize.height
        ), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}
// MARK: - TrackerViewControllerDelegate
extension TrackersViewController: TrackerViewControllerDelegate {
    func createTracker(_ tracker: Tracker?, category: String?) {
        guard let tracker = tracker, let category = category else { return }
        // TODO: Доделать в будущем проверку на дублирование трекера
        let trackerExists = categories.flatMap { $0.trackers }.contains { $0.id == tracker.id }
        
        if trackerExists {
            try? trackerStore.updateTracker(with: tracker)
        } else {
            do {
                try trackerCategoryStore.createTrackerWithCategory(tracker: tracker, with: category)
            } catch {
                print("failed create tracker")
            }
        }
        
        showVisibleCategories()
    }
}
// MARK: - RecordTrackerDelegate
extension TrackersViewController: TrackerCellDelegate {
    func updateTrackerRecord(on cell: TrackerCell) {
        let indexPath: IndexPath = collectionView.indexPath(for: cell) ?? IndexPath()
        let id = visibleCategories[indexPath.section].trackers[indexPath.row].id
        var daysCount = completedTrackers.filter { $0.id == id && areDatesEqualIgnoringTime(date1: $0.date, date2: currentDate) }.count
        let isToday = completedTrackers.contains { $0.id == id && areDatesEqualIgnoringTime(date1: $0.date, date2: currentDate) }
        let recordTracker = TrackerRecord(id: id, date: currentDate)
        
        if isToday {
            if isCompleteSelectedTracker[id] == nil || !(isCompleteSelectedTracker[id] ?? false ) {
                analyticsService.clickRecordTrackReport()
                daysCount += 1
                try? trackerRecordStore.addRecord(recordTracker)
                isCompleteSelectedTracker[id] = true
            } else {
                daysCount -= 1
                try? trackerRecordStore.deleteRecord(recordTracker)
                isCompleteSelectedTracker[id] = false
            }
        } else {
            if !(isCompleteSelectedTracker[id] ?? false) {
                analyticsService.clickRecordTrackReport()
                daysCount += 1
                try? trackerRecordStore.addRecord(recordTracker)
                isCompleteSelectedTracker[id] = true
            } else {
                daysCount -= 1
                try? trackerRecordStore.deleteRecord(recordTracker)
                isCompleteSelectedTracker[id] = false
            }
        }
        completedTrackers = trackerRecordStore.records
        cell.updateRecord(days: daysCount, isCompleted: isCompleteSelectedTracker[id] ?? false)
        collectionView.reloadData()
    }
    
    private func areDatesEqualIgnoringTime(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, equalTo: date2, toGranularity: .day)
    }
}
// MARK: - UITextFieldDelegate
extension TrackersViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        let updatedString = nsString?.replacingCharacters(in: range, with: string)
        
        guard let searchText = updatedString, !searchText.isEmpty else {
            showVisibleCategories()
            return true
        }
        filterCategories(with: searchText)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        showVisibleCategories()
        return true
    }
    
    private func filterCategories(with searchText: String) {
        visibleCategories = categories.map { category -> TrackerCategory in
            let filteredTrackers = category.trackers.filter { tracker -> Bool in
                let isNameMatching = tracker.name.lowercased().contains(searchText.lowercased())
                
                if let schedule = tracker.shedule, !schedule.isEmpty {
                    return isNameMatching && schedule.contains { $0 == getADay() }
                } else {
                    return isNameMatching
                }
            }
            
            let filteredCategory = TrackerCategory(title: category.title, trackers: filteredTrackers)
            
            return filteredCategory
        }.filter { $0.trackers.count > 0 }
        
        showBackgroundView(forCollection: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
// MARK: - FilterDelegate
extension TrackersViewController: FilterDelegate {
    func showAllTrackers() {
        showVisibleCategories()
    }
    
    func showTrackersForToday() {
        datePicker.date = Date()
        showVisibleCategories()
    }
    
    func showCompletedTrackersForSelectedDay() {
        showTrackersForSelectedDay(completed: true)
        showBackgroundView(forCollection: true)
    }
    
    func showUnCompletedTrackersForSelectedDay() {
        showTrackersForSelectedDay(completed: false)
        showBackgroundView(forCollection: true)
    }
    
    private func showTrackersForSelectedDay(completed: Bool) {
        let selectedTrackers = completedTrackers.filter { areDatesEqualIgnoringTime(date1: $0.date,
                                                                                                    date2: currentDate )}
        visibleCategories = categories.map { category -> TrackerCategory in
            let categories = category.trackers.filter { tracker in
                guard let shedule = tracker.shedule else { return true}

                if completed || !shedule.isEmpty {
                    return shedule.contains { $0 == getADay() }
                } else {
                    return !selectedTrackers.contains { $0.id == tracker.id }
                }
            }
            return TrackerCategory(title: category.title, trackers: categories)
        }.filter { !$0.trackers.isEmpty }
        
        
        isCompletedTracker()
    }
}
