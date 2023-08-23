//
//  CategoriesViewController.swift
//  Tracker
//

import UIKit

protocol AddNewСategoryViewControllerDelegate: AnyObject {
    func editCategory(_ editText: String)
    func addCategory(_ text: String)
}

final class CategoriesViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: view.bounds.size.width,
                                                  height: 500),
                                    style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .white
        return tableView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .BlackDay
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addNewCategory), for: .touchUpInside)
        return button
    }()
    
    let userDefaults = UserDefaults.standard
    
    weak var delegate: HabitDelegate?
    
    private var categories: [String] {
        get {
            if let savedData = UserDefaults.standard.data(forKey: "categories"),
               let loadedArray = try? JSONDecoder().decode([String].self, from: savedData) {
                return loadedArray
            } else {
                return [String]()
            }
        } set {
            let newData = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(newData, forKey: "categories")
            UserDefaults.standard.synchronize()
        }
    }
    
    private var editingIndexPath: IndexPath? {
        didSet {
            guard let indexPath = editingIndexPath else { return }
            let selectedRow = indexPath.row
            userDefaults.set(selectedRow, forKey: "editingIndexPath")
            userDefaults.synchronize()
        }
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedRow = userDefaults.object(forKey: "editingIndexPath") as? Int {
            editingIndexPath = IndexPath(row: savedRow, section: 0)
        }
        setupViews()
        updateTableView()
    }
    
    // MARK: - Layouts
    private func setupViews() {
        [tableView, addCategoryButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor),
            
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    // MARK: - Action
    @objc
    private func addNewCategory() {
        goToAddNewCategory(isEdit: false)
    }
    // MARK: - Functions
    private func goToAddNewCategory(isEdit: Bool = false, text: String? = nil) {
        let addNewCategoryViewController = AddNewCategoryViewController()
        addNewCategoryViewController.delegate = self
        addNewCategoryViewController.isEdit = isEdit
        addNewCategoryViewController.editText = text
        
        let navigationController = UINavigationController(rootViewController: addNewCategoryViewController)
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationBar.shadowImage = UIImage()
        present(navigationController, animated: true)
    }
    
    private func updateTableView() {
        if categories.isEmpty {
            let emptyView = EmptyView(frame: CGRect(
                x: 0,
                y: 0,
                width: view.bounds.width,
                height: view.bounds.height),
                                      text: "Привычки и события можно\nобъединить по смыслу")
            tableView.backgroundView = emptyView
        } else {
            tableView.backgroundView = nil
        }
        tableView.reloadData()
    }
}
// MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row]
        cell.backgroundColor = .defaultColor
        cell.accessoryType = indexPath == editingIndexPath ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let editingIndexPath = editingIndexPath {
            let previousSelectedCell = tableView.cellForRow(at: editingIndexPath)
            previousSelectedCell?.accessoryType = .none
        }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        editingIndexPath = indexPath
        
        delegate?.addDetailCategory(categories[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        editingIndexPath = indexPath
        
        let editAction = UIAction(title: "Редактировать") { [weak self] _ in
            guard let self = self else { return }
            
            if let editingIndexPath = self.editingIndexPath {
                let editText = self.categories[editingIndexPath.row]
                self.goToAddNewCategory(isEdit: true, text: editText)
            }
        }
        
        let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.categories.remove(at: indexPath.row)
            self.updateTableView()
        }
        
        let menu = UIMenu(title: "", children: [editAction, deleteAction])
        return UIContextMenuConfiguration(actionProvider:  { _ in
            menu
        })
    }
}
    // MARK: - AddNewcategoryViewControllerDelegate
extension CategoriesViewController: AddNewСategoryViewControllerDelegate {
    func editCategory(_ editText: String) {
        if let editingIndexPath = editingIndexPath {
            categories[editingIndexPath.row] = editText
            tableView.reloadRows(at: [editingIndexPath], with: .automatic)
        }
    }
    
    func addCategory(_ text: String) {
        categories.append(text)
        updateTableView()
    }
}