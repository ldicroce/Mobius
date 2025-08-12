//
//  StandTimerViewModel.swift
//  Mobius
//
//  Updated for: 60‑min countdown, 10‑min pre‑alert, count‑up after zero,
//  switch control, persistent logs, and compatibility with your current ContentView.
//

import Foundation
import Combine

final class StandTimerViewModel: ObservableObject {
    // MARK: - Configuration
    let total: TimeInterval = 10// 60 * 60          // 60 minutes
    let preAlertWindow: TimeInterval = 2 // 10 * 60 // last 10 minutes

    // MARK: - Published UI State
    @Published var isEnabled: Bool = false {   // switch ON/OFF drives start/pause
        didSet { isEnabled ? startOrResume() : pause() }
    }
    @Published var remaining: TimeInterval     // seconds left during countdown
    @Published var isInPreAlert: Bool = false  // true in last 10 mins (and during count‑up)

    // Count‑up (overtime) phase
    @Published var isCountingUp: Bool = false
    @Published var elapsedAfterZero: TimeInterval = 0

    // Log of “I stood up” taps (latest first)
    @Published var logs: [Date] = []

    // MARK: - Internals
    private var endDate: Date?                 // target end for countdown
    private var countUpStart: Date?            // start time for count‑up
    private var ticker: AnyCancellable?

    // Persistence key
    private let storeKey = "StandTimerLogs"

    // MARK: - Init
    init() {
        remaining = total

        // 1 Hz tick (light on CPU, enough for mm:ss)
        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }

        loadLogs()
    }

    // MARK: - User Actions

    /// User confirms they stood up: log now, restart a fresh 60‑minute countdown, keep switch state.
    func stoodUpNow() {
        logs.insert(Date(), at: 0)
        saveLogs()

        // Reset all timers/state
        remaining = total
        isCountingUp = false
        elapsedAfterZero = 0
        countUpStart = nil
        isInPreAlert = false
        endDate = nil

        if isEnabled {
            // Immediately resume countdown
            endDate = Date().addingTimeInterval(remaining)
        }
    }

    /// Cancel everything and reset to initial state (switch OFF).
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
            // Resume count‑up from where we left off
            if countUpStart == nil {
                countUpStart = Date().addingTimeInterval(-elapsedAfterZero)
            }
            // isInPreAlert stays true during overtime
            isInPreAlert = true
        } else {
            // Resume countdown from remaining
            endDate = Date().addingTimeInterval(remaining)
            // Update pre‑alert immediately in case we resume inside last 10 mins
            isInPreAlert = remaining <= preAlertWindow
        }
    }

    private func pause() {
        if isCountingUp {
            // Capture elapsed so we can resume later
            if let start = countUpStart {
                elapsedAfterZero = max(0, Date().timeIntervalSince(start))
            }
            countUpStart = nil
        } else {
            // Capture remaining so we can resume later
            if let end = endDate {
                remaining = max(0, end.timeIntervalSinceNow)
            }
            endDate = nil
        }
    }

    private func tick() {
        guard isEnabled else { return }

        if isCountingUp {
            // Overtime: keep counting up
            if let start = countUpStart {
                elapsedAfterZero = max(0, Date().timeIntervalSince(start))
            } else {
                // If somehow nil, start now
                countUpStart = Date()
                elapsedAfterZero = 0
            }
            isInPreAlert = true   // keep warning visuals during overtime
            return
        }

        // Normal countdown
        guard let end = endDate else { return }
        remaining = max(0, end.timeIntervalSinceNow)
        isInPreAlert = remaining <= preAlertWindow

        if remaining == 0 {
            switchToCountUp()
        }
    }

    private func switchToCountUp() {
        isCountingUp = true
        isInPreAlert = true
        elapsedAfterZero = 0
        countUpStart = Date()
        endDate = nil
    }

    // MARK: - Persistence

    private func saveLogs() {
        let timestamps = logs.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(timestamps, forKey: storeKey)
    }

    private func loadLogs() {
        let timestamps = UserDefaults.standard.array(forKey: storeKey) as? [TimeInterval] ?? []
        logs = timestamps.sorted(by: >).map { Date(timeIntervalSince1970: $0) }
    }
}
