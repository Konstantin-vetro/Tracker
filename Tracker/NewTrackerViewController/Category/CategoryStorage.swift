//
//  CategoryStorage.swift
//  Tracker
//

import Foundation

@propertyWrapper
struct CategoryStorage {
    private let key: String
    private let userDefaults = UserDefaults.standard
    
    var wrappedValue: [String] {
        get { userDefaults.object(forKey: key) as? [String] ?? [] }
        set { userDefaults.setValue(newValue, forKey: key) }
    }
    
    init(_ key: String) {
        self.key = key
    }
}
