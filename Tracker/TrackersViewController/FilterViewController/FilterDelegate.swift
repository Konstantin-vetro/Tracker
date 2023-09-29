//
//  FilterViewControllerDelegate.swift
//  Tracker
//
//  Created by Гость on 07.09.2023.
//

import Foundation

protocol FilterDelegate: AnyObject {
    func showAllTrackers()
    func showTrackersForToday()
    func showCompletedTrackersForSelectedDay()
    func showUnCompletedTrackersForSelectedDay()
}
