import Foundation

// TODO: test
class GameTimer {
    var timer: Timer?
    var count: Int = 0
    var timeInMinSec: (min: Int, sec: Int) {
        let min = Int(floor(Double(count) / 60.0))
        let sec = count % 60
        return (min, sec)
    }

    func start(timeInSeconds time: Int) {
        count = time
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { self.decrement($0) })
    }

    func decrement(_: Timer) {
        count -= 1
        NotificationCenter.default.post(name: .timerUpdate, object: timeInMinSec)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
