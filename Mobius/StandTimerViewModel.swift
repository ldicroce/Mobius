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
    let preAlertWindow: TimeInterval = 3// 10 * 60 // last 10 minutes

    // UI state
    @Published var isEnabled = false {
        didSet { isEnabled ? startOrResume() : pause() }
    }
    @Published var remaining: TimeInterval
    @Published var isInPreAlert = false

    // Count-up phase (after time reaches 0)
    @Published var isCountingUp = false
    @Published var elapsedAfterZero: TimeInterval = 0

    // Logs
    @Published var logs: [Date] = []

    // Internals
    private var endDate: Date?
    private var ticker: AnyCancellable?
    private var countUpStart: Date?

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
        // Log, reset to a fresh 60 minutes, keep running if enabled
        logs.insert(Date(), at: 0)
        saveLogs()

        // Reset all counters
        remaining = total
        isCountingUp = false
        elapsedAfterZero = 0
        countUpStart = nil
        isInPreAlert = false

        if isEnabled { endDate = Date().addingTimeInterval(remaining) }
    }

    func cancel() {
        isEnabled = false
        remaining = total
        endDate = nil
        isInPreAlert = false

        isCountingUp = false
        elapsedAfterZero = 0
        countUpStart = nil
    }

    // MARK: - Engine

    private func startOrResume() {
        if isCountingUp {
            // resume count-up
            countUpStart = Date().addingTimeInterval(-elapsedAfterZero)
        } else {
            // resume countdown
            endDate = Date().addingTimeInterval(remaining)
        }
    }

    private func pause() {
        if isCountingUp {
            // capture elapsed and stop ticking up
            if let start = countUpStart {
                elapsedAfterZero = max(0, Date().timeIntervalSince(start))
            }
            countUpStart = nil
        } else {
            // capture remaining and stop countdown
            if let end = endDate {
                remaining = max(0, end.timeIntervalSinceNow)
            }
            endDate = nil
        }
    }

    private func tick() {
        guard isEnabled else { return }

        if isCountingUp {
            // keep counting up
            elapsedAfterZero = max(0, Date().timeIntervalSince(countUpStart ?? Date()))
            isInPreAlert = true // keep warning state while counting up
            return
        }

        // normal countdown
        guard let end = endDate else { return }
        remaining = max(0, end.timeIntervalSinceNow)

        // enter pre-alert in last 10 minutes
        isInPreAlert = remaining <= preAlertWindow

        if remaining == 0 {
            // switch to count-up mode
            isCountingUp = true
            countUpStart = Date()
            elapsedAfterZero = 0
            isInPreAlert = true
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
