//
//  TrackersViewControllerDelegate.swift
//  Tracker
//

import Foundation

protocol TrackerViewControllerDelegate: AnyObject {
    func createTracker(_ tracker: Tracker?, category: String?)
}
