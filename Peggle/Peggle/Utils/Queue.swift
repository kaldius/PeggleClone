/**
 A first-in first-out queue.
 */

struct Queue<T>: Equatable where T: Equatable {

    private var queueArray = [T]()

    /// Adds an element to the tail of the queue.
    /// - Parameter item: The element to be added to the queue
    mutating func enqueue(_ item: T) {
        queueArray.append(item)
    }

    /// Removes an element from the head of the queue and return it.
    /// - Returns: item at the head of the queue, nil if the queue is empty
    mutating func dequeue() -> T? {
        if self.isEmpty {
            return nil
        } else {
            return queueArray.removeFirst()
        }
    }

    /// Returns, but does not remove, the element at the head of the queue.
    /// - Returns: item at the head of the queue
    func peek() -> T? {
        queueArray.first
    }

    /// The number of elements currently in the queue.
    var count: Int {
        queueArray.count
    }

    /// Whether the queue is empty.
    var isEmpty: Bool {
        queueArray.isEmpty
    }

    /// Removes all elements in the queue.
    mutating func removeAll() {
        queueArray.removeAll()
    }

    /// Returns an array of the elements in their respective dequeue order, i.e.
    /// first element in the array is the first element to be dequeued.
    /// - Returns: array of elements in their respective dequeue order
    func toArray() -> [T] {
        queueArray
    }
}
