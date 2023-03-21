/**
 The `LevelDataSource` protocol defines a set of methods that must be implemented
 by any class provides a `Level` for another class.
 */

protocol LevelDataSource: AnyObject {
    func getLevelName() -> String?
}
