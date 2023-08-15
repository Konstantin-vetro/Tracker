//
//  TrackerCategory.swift
//  Tracker
//

///сущность для хранения трекеров по категориям;
///имеет заголовок и массив трекеров, относящихся к этой категории

import Foundation

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}
