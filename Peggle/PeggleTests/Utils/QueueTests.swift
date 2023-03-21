import XCTest
@testable import Peggle

final class QueueTests: XCTestCase {

    var emptyQueue: Queue<Int>!
    var intQueue: Queue<Int>!

    override func setUp() {
        super.setUp()
        emptyQueue = Queue()
        intQueue = Queue()
        intQueue.enqueue(1)
        intQueue.enqueue(2)
        intQueue.enqueue(3)
    }

    override func tearDown() {
        emptyQueue = nil
        intQueue = nil
        super.tearDown()
    }

    func testEnqueueDequeue_emptyQueue_hasCorrectOrder() {
        let enqueueSequence = [5, 6, 7, 1, 2, 3]
        let expectedDequeueOutputs = enqueueSequence

        for item in enqueueSequence {
            emptyQueue.enqueue(item)
        }

        var dequeueOutputs = [Int]()

        for _ in 0..<enqueueSequence.count {
            guard let dequeuedValue = emptyQueue.dequeue() else {
                continue
            }
            dequeueOutputs.append(dequeuedValue)
        }

        XCTAssertEqual(dequeueOutputs, expectedDequeueOutputs, "Enqueue-dequeue order is incorrect")
    }

    func testDequeue_emptyQueue_isNil() {
        XCTAssertNil(emptyQueue.dequeue(), "Dequeuing empty queue should return 'nil'")
    }

    func testDequeue_intQueue_hasCorrectOrder() {
        XCTAssertEqual(intQueue.dequeue(), 1, "Third element dequeued should be '1'")
        XCTAssertEqual(intQueue.dequeue(), 2, "Second element dequeued should be '2'")
        XCTAssertEqual(intQueue.dequeue(), 3, "First element dequeued should be '3'")
    }

    func testPeek_intQueue_hasCorrectOrder() {
        XCTAssertEqual(intQueue.peek(), 1, "Third element peeked should be '1'")
        _ = intQueue.dequeue()
        XCTAssertEqual(intQueue.peek(), 2, "Second element peeked should be '2'")
        _ = intQueue.dequeue()
        XCTAssertEqual(intQueue.peek(), 3, "First element peeked should be '3'")
    }

    func testPeek_repeatedPeeks_sameResult() {
        XCTAssertEqual(intQueue.peek(), 1, "Repeated peeking should return the same value")
        XCTAssertEqual(intQueue.peek(), 1, "Repeated peeking should return the same value")
        XCTAssertEqual(intQueue.peek(), 1, "Repeated peeking should return the same value")
    }

    func testPeek_emptyQueue_isNil() {
        XCTAssertNil(emptyQueue.peek(), "Peeking empty queue should return 'nil'")
    }

    func testCount_emptyQueue_isZero() {
        XCTAssertEqual(emptyQueue.count, 0, "Count of empty queue should be '0'")
        _ = emptyQueue.dequeue()
        XCTAssertEqual(emptyQueue.count, 0, "Count of empty queue should be '0'")
    }

    func testCount_intQueue_correctCount() {
        XCTAssertEqual(intQueue.count, 3, "Count of elements in queue should be 3")
    }

    func testIsEmpty_emptyQueue_isTrue() {
        XCTAssertTrue(emptyQueue.isEmpty, "Empty queue's isEmpty should be 'true'")
    }

    func testIsEmpty_intQueue_isFalse() {
        XCTAssertFalse(intQueue.isEmpty, "Populated queue's isEmpty should be 'false'")
    }

    func testRemoveAll_emptyQueue_isEmpty() {
        emptyQueue.removeAll()

        XCTAssertTrue(emptyQueue.isEmpty, "Empty queue should remain empty after removing all elements")
    }

    func testRemoveAll_intQueue_isEmpty() {
        intQueue.removeAll()

        XCTAssertTrue(intQueue.isEmpty, "Populated queue should be empty after removing all elements")
    }

    func testToArray_emptyQueue_isEmpty() {
        let emptyArray = emptyQueue.toArray()

        XCTAssertEqual(emptyArray, [], "Empty queue should return an empty array.")
    }

    func testToArray_intQueue_hasCorrectOrder() {
        let intArray = intQueue.toArray()

        XCTAssertEqual(intArray, [1, 2, 3], "Populated queue returned the wrong array")
    }
}
