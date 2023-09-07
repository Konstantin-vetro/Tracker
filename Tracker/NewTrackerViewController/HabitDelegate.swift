//
//  HabitDelegate.swift
//  Tracker
//

import Foundation

protocol HabitDelegate: AnyObject {
    func addDetailCategory(_ text: String)
    func addDetailDays(_ days: [String])
}
