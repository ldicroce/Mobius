//
//  StandTimerViewModel.swift
//  Mobius
//
//  Created by Luciano Di Croce on 11/8/25.
//

import Foundation
import Combine

final class StandTimerViewModel: ObservableObject {
    // Config
    let total: TimeInterval = 10// 60 * 60          // 60 minutes
    let preAlertWindow: TimeInterval = 2// 10 * 60 // last 10 minutes

    // UI state
    @Published var isEnabled = false {
        didSet { isEnabled ? startOrResume() : pause() }
    }
    @Published var remaining: TimeInterval
    @Published var isInPreAlert = false
    @Published var logs: [Date] = []

    // Internals
    private var endDate: Date?
    private var ticker: AnyCancellable?

    init() {
        remaining = total

        // 1 Hz tick to keep CPU light
        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }

        loadLogs()
    }

    // MARK: - Controls

    func toggleEnabled(_ on: Bool) { isEnabled = on }

    func stoodUpNow() {
        logs.insert(Date(), at: 0)
        saveLogs()
        remaining = total
        if isEnabled { endDate = Date().addingTimeInterval(remaining) }
        isInPreAlert = false
    }

    func cancel() {
        isEnabled = false
        remaining = total
        endDate = nil
        isInPreAlert = false
    }

    // MARK: - Engine

    private func startOrResume() {
        endDate = Date().addingTimeInterval(remaining)
    }

    private func pause() {
        if let end = endDate { remaining = max(0, end.timeIntervalSinceNow) }
        endDate = nil
    }

    private func tick() {
        guard isEnabled, let end = endDate else { return }
        remaining = max(0, end.timeIntervalSinceNow)

        let wasPreAlert = isInPreAlert
        isInPreAlert = remaining <= preAlertWindow
        if isInPreAlert && !wasPreAlert {
            // Placeholder for notifications in next iteration
        }

        if remaining == 0 {
            isEnabled = false
            endDate = nil
        }
    }

    // MARK: - Persistence

    private let storeKey = "StandTimerLogs"

    private func saveLogs() {
        let timestamps = logs.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(timestamps, forKey: storeKey)
    }

    private func loadLogs() {
        let timestamps = UserDefaults.standard.array(forKey: storeKey) as? [TimeInterval] ?? []
        logs = timestamps.sorted(by: >).map { Date(timeIntervalSince1970: $0) }
    }
}
