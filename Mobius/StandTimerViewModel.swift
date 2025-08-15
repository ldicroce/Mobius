//
//  StandTimerViewModel.swift
//  Mobius
//
//  Updated for: 60‑min countdown, 10‑min pre‑alert, count‑up after zero,
//  switch control, persistent logs, and compatibility with your current ContentView.
//

//
//  StandTimerViewModel.swift
//  Mobius
//
//  60‑min countdown, 10‑min pre‑alert, count‑up after zero,
//  switch control, persistent logs, and optional auto‑restart with Off/1m/2m/5m.
//

import Foundation
import Combine

final class StandTimerViewModel: ObservableObject {
    // MARK: - Configuration
    let total: TimeInterval = 10 //60 * 60          // 60 minutes
    let preAlertWindow: TimeInterval = 2 //10 * 60 // last 10 minutes

    // MARK: - Auto-restart settings
    enum AutoRestartSetting: TimeInterval, CaseIterable {
        case off = 0
        case oneMinute = 60
        case twoMinutes = 120
        case fiveMinutes = 300

        var label: String {
            switch self {
            case .off: return "Off"
            case .oneMinute: return "1 min"
            case .twoMinutes: return "2 min"
            case .fiveMinutes: return "5 min"
            }
        }
    }
    @Published var autoRestartSetting: AutoRestartSetting = .off

    // MARK: - Published UI State
    @Published var isEnabled: Bool = false {   // switch ON/OFF drives start/pause
        didSet { isEnabled ? startOrResume() : pause() }
    }
    @Published var remaining: TimeInterval
    @Published var isInPreAlert: Bool = false

    // Count‑up (overtime)
    @Published var isCountingUp: Bool = false
    @Published var elapsedAfterZero: TimeInterval = 0

    // Logs
    @Published var logs: [Date] = []

    // MARK: - Internals
    private var endDate: Date?
    private var countUpStart: Date?
    private var ticker: AnyCancellable?
    private var didAutoRestartThisCycle = false

    private let storeKey = "StandTimerLogs"

    // MARK: - Init
    init() {
        remaining = total

        // 1 Hz tick (light on CPU)
        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }

        loadLogs()
    }

    // MARK: - User Actions

    func stoodUpNow() {
        restartCycleAndLogNow()
    }

    func cancel() {
        isEnabled = false
        remaining = total
        endDate = nil
        isInPreAlert = false

        isCountingUp = false
        elapsedAfterZero = 0
        countUpStart = nil
        didAutoRestartThisCycle = false
    }

    // MARK: - Engine

    private func startOrResume() {
        if isCountingUp {
            if countUpStart == nil {
                countUpStart = Date().addingTimeInterval(-elapsedAfterZero)
            }
            isInPreAlert = true
        } else {
            endDate = Date().addingTimeInterval(remaining)
            isInPreAlert = remaining <= preAlertWindow
        }
    }

    private func pause() {
        if isCountingUp {
            if let start = countUpStart {
                elapsedAfterZero = max(0, Date().timeIntervalSince(start))
            }
            countUpStart = nil
        } else {
            if let end = endDate {
                remaining = max(0, end.timeIntervalSinceNow)
            }
            endDate = nil
        }
    }

    private func tick() {
        guard isEnabled else { return }

        if isCountingUp {
            if let start = countUpStart {
                elapsedAfterZero = max(0, Date().timeIntervalSince(start))
            } else {
                countUpStart = Date()
                elapsedAfterZero = 0
            }
            isInPreAlert = true

            // Auto-restart after threshold if not Off (once per overtime phase)
            if autoRestartSetting != .off,
               !didAutoRestartThisCycle,
               elapsedAfterZero >= autoRestartSetting.rawValue {
                didAutoRestartThisCycle = true
                restartCycleAndLogNow()
            }
            return
        }

        // Countdown
        guard let end = endDate else { return }
        remaining = max(0, end.timeIntervalSinceNow)
        isInPreAlert = remaining <= preAlertWindow
        if remaining == 0 { switchToCountUp() }
    }

    private func switchToCountUp() {
        isCountingUp = true
        isInPreAlert = true
        elapsedAfterZero = 0
        countUpStart = Date()
        endDate = nil
        didAutoRestartThisCycle = false
    }

    private func restartCycleAndLogNow() {
        logs.insert(Date(), at: 0)
        saveLogs()

        // Reset to a fresh cycle
        remaining = total
        isCountingUp = false
        elapsedAfterZero = 0
        countUpStart = nil
        isInPreAlert = false
        endDate = nil
        didAutoRestartThisCycle = false

        if isEnabled {
            endDate = Date().addingTimeInterval(remaining)
        }
    }

    // MARK: - Persistence
    func clearLogs() {
           logs.removeAll()
           saveLogs()
       }
    
    private func saveLogs() {
        let timestamps = logs.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(timestamps, forKey: storeKey)
    }

    private func loadLogs() {
        let timestamps = UserDefaults.standard.array(forKey: storeKey) as? [TimeInterval] ?? []
        logs = timestamps.sorted(by: >).map { Date(timeIntervalSince1970: $0) }
    }
    
}

extension StandTimerViewModel {
    var gaugeProgress: Double {
        isCountingUp ? 1 : min(max(1 - remaining / total, 0), 1)
    }
    var centerLabel: String {
        let t = isCountingUp ? elapsedAfterZero : remaining
        return String(format: "%02d:%02d", Int(t)/60, Int(t)%60)
    }
}
