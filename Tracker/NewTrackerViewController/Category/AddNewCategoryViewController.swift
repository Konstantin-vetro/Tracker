//
//  AddNewCategoryViewController.swift
//  Tracker
//

import UIKit

final class AddNewCategoryViewController: UIViewController {
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 30))
        textField.leftViewMode = .always
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .defaultColor
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.clipsToBounds = true
        textField.becomeFirstResponder()
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .Gray
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(saveCategory), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    weak var delegate: AddNewСategoryViewControllerDelegate?
    
    var isEdit: Bool = false
    
    var editText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        editCategory()
        title = isEdit ? "Редактировать" : "Новая категория"
    }
    // MARK: - Layouts
    private func setupViews() {
        [textField, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 60),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    // MARK: - Action
    @objc
    private func saveCategory() {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if isEdit {
            delegate?.editCategory(text)
        } else {
            delegate?.addCategory(text)
        }
        dismiss(animated: true)
    }
    // MARK: - EditCategory
    private func editCategory() {
        if isEdit {
            textField.text = editText
            
            doneButton.backgroundColor = .BlackDay
            doneButton.setTitleColor(.white, for: .normal)
            doneButton.isEnabled = true
        }
    }
}
    // MARK: - UITextFieldDelegate
extension AddNewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        if newText.isEmpty || newText.first == " " {
            doneButton.backgroundColor = .Gray
            doneButton.setTitleColor(.white, for: .normal)
            doneButton.isEnabled = false
            return newText != " "
        } else {
            doneButton.backgroundColor = .BlackDay
            doneButton.setTitleColor(.white, for: .normal)
            doneButton.isEnabled = true
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.isEmpty == true {
            doneButton.backgroundColor = .Gray
            doneButton.setTitleColor(.white, for: .normal)
        }
    }
}
