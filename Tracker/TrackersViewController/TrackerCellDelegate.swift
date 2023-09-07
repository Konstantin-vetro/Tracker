//
//  TrackerCellDelegate.swift
//  Tracker
//

import Foundation

protocol TrackerCellDelegate: AnyObject {
    func updateTrackerRecord(on cell: TrackerCell)
}
