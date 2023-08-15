//
//  TrackerRecord.swift
//  Tracker
//

///сущность для хранения записи о том, что некий трекер был выполнен на некоторую дату;
///хранит id трекера, который был выполнен и дату выполнения

import UIKit

struct TrackerRecord: Hashable {
    let id: UUID
    let date: Date
}
