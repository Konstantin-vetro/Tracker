//
//  Models.swift
//  Tracker
//

///сущность для хранения информации про трекер
///(для «Привычки» или «Нерегулярного события»)

import UIKit

struct Tracker  {
    let id: UUID
    let name: String
    let color: UIColor
    let emojie: String
    let shedule: [String]?
}
