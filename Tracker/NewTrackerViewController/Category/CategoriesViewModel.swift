//
//  CategoriesViewModel.swift
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
//1
final class CategoriesViewModel: CategoriesViewModelProtocol {
    private var categoryStore: TrackerCategoryStore
    var categories: [TrackerCategory] = []
    
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.categoryStore = categoryStore
        do {
            try fetchCategories()
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
        }
    }
    
    private func fetchCategories() throws {
        categories = try categoryStore.getCategories()
    }

    func categoriesCount() -> Int {
        return categories.count
    }
    
    func categoryTitle(for indexPath: IndexPath) -> String {
        return categories[indexPath.row].title
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        do {
            let category = categories[indexPath.row]
            try categoryStore.deleteCategory(with: category.title)
            categories.remove(at: indexPath.row)
        } catch {
            print("Error deleting category: \(error.localizedDescription)")
        }
    }
    
    func editCategory(at indexPath: IndexPath, with newText: String) {
        let oldCategory = categories[indexPath.row]
        do {
            let newCategory = TrackerCategory(title: newText, trackers: oldCategory.trackers)
            try categoryStore.updateCategory(oldCategory, with: newText)
            categories[indexPath.row] = newCategory
            try fetchCategories()
        } catch {
            print("Error editing category: \(error.localizedDescription)")
        }
    }

    func addCategory(_ text: String) {
        do {
            let newCategory = TrackerCategory(title: text, trackers: [])
            try categoryStore.createCategory(newCategory)
            try fetchCategories()
        } catch {
            print("Error adding category: \(error.localizedDescription)")
        }
    }
    
    func isEmpty() -> Bool {
        return categories.isEmpty
    }
}
