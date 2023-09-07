//
//  CategoriesViewController.swift
//  Tracker
//

import UIKit

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
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .BlackDay
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addNewCategory), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let userDefaults = UserDefaults.standard
    private var viewModel: CategoriesViewModelProtocol
    
    weak var delegate: HabitDelegate?
    
    private var editingIndexPath: IndexPath? {
        didSet {
            guard let indexPath = editingIndexPath else { return }
            let selectedRow = indexPath.row
            userDefaults.set(selectedRow, forKey: "editingIndexPath")
            userDefaults.synchronize()
        }
    }
    
    init(viewModel: CategoriesViewModelProtocol = CategoriesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedRow = userDefaults.object(forKey: "editingIndexPath") as? Int {
            editingIndexPath = IndexPath(row: savedRow, section: 0)
        }
        setupViews()
        updateTableView(forTable: true)
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
    
    private func updateTableView(forTable: Bool) {
        if viewModel.isEmpty() {
            let emptyView = EmptyView(frame: CGRect(
                x: 0,
                y: 0,
                width: view.bounds.width,
                height: view.bounds.height),
                                      useImage: forTable,
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
        return viewModel.categoriesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = viewModel.categoryTitle(for: indexPath)
        cell.backgroundColor = .defaultColor
        cell.accessoryType = indexPath == editingIndexPath ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteCategory(at: indexPath)
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
        
        delegate?.addDetailCategory(viewModel.categories[indexPath.row].title)
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
                let editText = self.viewModel.categories[editingIndexPath.row].title
                self.goToAddNewCategory(isEdit: true, text: editText)
            }
        }
        
        let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.deleteCategory(at: indexPath)
            self.updateTableView(forTable: true)
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
            viewModel.editCategory(at: editingIndexPath, with: editText)
            tableView.reloadRows(at: [editingIndexPath], with: .automatic)
        }
    }
    
    func addCategory(_ text: String) {
        viewModel.addCategory(text)
        updateTableView(forTable: true)
    }
}
