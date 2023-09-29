//
//  AnaliticsService.swift
//  Tracker
//

import Foundation
import YandexMobileMetrica

struct AnalyticsService: AnalyticsServiceProtocol {
    func activateAnalytics() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "fd4abd52-263c-4254-b969-fc026a7624eb") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func openScreenReport(screen: ScreenName) {
        report(event: "open", params: ["screen" : "\(screen)"])
    }
    
    func closeScreenReport(screen: ScreenName) {
        report(event: "close", params: ["screen" : "\(screen)"])
    }

    func addTrackReport() {
        report(event: "click", params: ["screen" : "Main", "item" : "add_track"])
    }
    
    func addFilterReport() {
        report(event: "click", params: ["screen" : "Main", "item" : "filter"])
    }
    
    func editTrackReport() {
        report(event: "click", params: ["screen" : "Main", "item" : "edit"])
    }
    
    func deleteTrackReport() {
        report(event: "click", params: ["screen" : "Main", "item" : "delete"])
    }
    
    func clickRecordTrackReport() {
        report(event: "click", params: ["screen" : "Main", "item" : "track"])
    }
    
    func clickHabitReport() {
        report(event: "click", params: ["screen" : "TrackersType", "item" : "add_habit"])
    }
    
    func clickEventReport() {
        report(event: "click", params: ["screen" : "TrackersType", "item" : "add_event"])
    }
    
    func clickCreateTrackerReport() {
        report(event: "click", params: ["screen" : "NewTracker", "item" : "create_track"])
    }
    
    func clickExitViewForNewTracker() {
        report(event: "click", params: ["screen" : "NewTracker", "item" : "exit_view"])
    }
    
    private func report(event: String, params: [AnyHashable : String]) {
        YMMYandexMetrica.reportEvent(event, parameters: params) { error in
            print("REPORT ERROR %@", error.localizedDescription)
        }
    }
}
