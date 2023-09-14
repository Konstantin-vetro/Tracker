//
//  AnalyticsServiceProtocol.swift
//  Tracker
//

protocol AnalyticsServiceProtocol: Any {
    func openScreenReport(screen: ScreenName)
    func closeScreenReport(screen: ScreenName)
    func addTrackReport()
    func editTrackReport()
    func deleteTrackReport()
    func addFilterReport()
    func clickRecordTrackReport()
    func clickHabitReport()
    func clickEventReport()
    func clickCreateTrackerReport()
    func clickExitViewForNewTracker()
}
