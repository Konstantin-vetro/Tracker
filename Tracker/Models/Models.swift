//
//  Models.swift
//  Tracker
//

import UIKit

struct Tracker  {
    let id: UUID
    let name: String
    let color: UIColor
    let emojie: String
    let shedule: [String]?
}

struct TrackerCategory {
    var title: String
    var trackers: [Tracker]
}

struct TrackerRecord: Hashable {
    let id: UUID
    let date: Date
}
