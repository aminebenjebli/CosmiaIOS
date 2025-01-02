import Foundation
import Combine

class CountTimer: ObservableObject {
    @Published var progress: Double = 0.0
    private var interval: TimeInterval
    private var max: Int
    private let publisher: Timer.TimerPublisher
    private var cancellable: Cancellable?

    init(items: Int, interval: TimeInterval) {
        self.max = items
        self.interval = interval
        self.publisher = Timer.publish(every: 0.1, on: .main, in: .default)
    }

    func start() {
        cancellable?.cancel()
        self.cancellable = self.publisher.autoconnect().sink { _ in
            var newProgress = self.progress + (0.1 / self.interval)
            if Int(newProgress) >= self.max {
                self.stop() // Stop timer when the last image is reached
            }
            self.progress = newProgress
        }
    }

    func advancePage(by number: Int) {
        let newProgress = Swift.max(min(Int(self.progress) + number, self.max - 1), 0)
        self.progress = Double(newProgress)
    }

    func stop() {
        cancellable?.cancel()
        cancellable = nil
    }

    func updateMax(_ newMax: Int) {
        self.max = newMax
        self.progress = 0
    }
}
