//
//  AddNewViewControllerDelegate.swift
//  Tracker
//

import Foundation

protocol AddNewСategoryViewControllerDelegate: AnyObject {
    func editCategory(_ editText: String)
    func addCategory(_ text: String)
}
