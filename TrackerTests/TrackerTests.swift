//
//  TrackerTests.swift
//  TrackerTests
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testLightViewController() {
        let vc = TrackersViewController()
        assertSnapshot(matching: vc, as: .image(traits: UITraitCollection(userInterfaceStyle: .light)))
    }

    func testDarktViewController() {
        let vc = TrackersViewController()
        assertSnapshot(matching: vc, as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)))
    }
}
