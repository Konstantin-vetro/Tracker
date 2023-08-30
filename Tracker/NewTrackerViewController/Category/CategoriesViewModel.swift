//
//  CategoriesViewModel.swift
//  Tracker
//

import Foundation

final class CategoriesViewModel {
    @CategoryStorage("categoriesKey")
    var categories: [String]

    func numberOfRows() -> Int {
        return categories.count
    }
    
    func heightForRowAt(indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func categoryTitle(for indexPath: IndexPath) -> String {
        return categories[indexPath.row]
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        categories.remove(at: indexPath.row)
    }
    
    func editCategory(at indexPath: IndexPath, with newText: String) {
        categories[indexPath.row] = newText
    }
    
    func addCategory(_ text: String) {
        categories.append(text)
    }
    
    func isEmpty() -> Bool {
        return categories.isEmpty
    }
}
