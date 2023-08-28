//
//  WeekdaysMarshalling.swift
//  Tracker
//

import Foundation

final class WeekDayMarshalling {
    private let weekdays: [String] = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    func makeStringFromArray(_ shedule: [String]) -> String {
        var string = ""
        for day in weekdays {
            if shedule.contains(day) {
                string += "1"
            } else {
                string += "0"
            }
        }
        
        return string
    }
    
    func makeWeekDayArrayFromString(shedule: String?) -> [String] {
        var array: [String] = []
        if let shedule = shedule {
            shedule.enumerated().forEach { index, character in
                if character == "1" {
                    array.append(weekdays[index])
                }
            }
        }
        
        return array
    }
}
