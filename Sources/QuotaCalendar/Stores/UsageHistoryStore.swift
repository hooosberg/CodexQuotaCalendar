import Foundation

struct UsageHistoryStore {
    private let key = "usageSamples"
    private let defaults: UserDefaults
    private let minimumPersistentInterval: TimeInterval
    private let maxPersistentSamples: Int

    init(
        defaults: UserDefaults = .standard,
        minimumPersistentInterval: TimeInterval = 30 * 60,
        maxPersistentSamples: Int = 20
    ) {
        self.defaults = defaults
        self.minimumPersistentInterval = minimumPersistentInterval
        self.maxPersistentSamples = maxPersistentSamples
    }

    func loadSamples() -> [UsageSample] {
        guard let data = defaults.data(forKey: key),
              let samples = try? JSONDecoder().decode([UsageSample].self, from: data) else {
            return []
        }
        return samples.sorted { $0.capturedAt < $1.capturedAt }
    }

    func saveSamples(_ samples: [UsageSample]) {
        let trimmed = Array(samples.sorted { $0.capturedAt < $1.capturedAt }.suffix(maxPersistentSamples))
        guard let data = try? JSONEncoder().encode(trimmed) else { return }
        defaults.set(data, forKey: key)
    }

    func appending(snapshot: UsageSnapshot, now: Date) -> [UsageSample] {
        guard let weeklyUsed = snapshot.oneWeek?.usedPercent else {
            return loadSamples()
        }
        let current = UsageSample(capturedAt: now, weeklyUsedPercent: weeklyUsed)
        var samples = loadSamples()

        if shouldPersist(current, after: samples.last) {
            samples.append(current)
            saveSamples(samples)
            return loadSamples()
        }

        return samples + [current]
    }

    private func shouldPersist(_ current: UsageSample, after previous: UsageSample?) -> Bool {
        guard let previous else { return true }
        if current.weeklyUsedPercent < previous.weeklyUsedPercent {
            return true
        }
        return current.capturedAt.timeIntervalSince(previous.capturedAt) >= minimumPersistentInterval
    }
}
