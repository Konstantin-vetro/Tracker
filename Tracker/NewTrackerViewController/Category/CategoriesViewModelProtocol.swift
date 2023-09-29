//
//  CategoriesViewModelProtocol.swift
//  Tracker
//

import Foundation

protocol CategoriesViewModelProtocol: AnyObject {
    var categories: [TrackerCategory] { get set }
    func categoriesCount() -> Int
    func categoryTitle(for indexPath: IndexPath) -> String
    func deleteCategory(at indexPath: IndexPath)
    func editCategory(at indexPath: IndexPath, with newText: String)
    func addCategory(_ text: String)
    func isEmpty() -> Bool
}
