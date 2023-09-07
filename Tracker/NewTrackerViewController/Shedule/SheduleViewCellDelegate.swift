//
//  SheduleViewCellDelegate.swift
//  Tracker
//

import Foundation

protocol SheduleViewCellDelegate: AnyObject {
    func didToogleSwitch(for day: String, isOn: Bool)
}
