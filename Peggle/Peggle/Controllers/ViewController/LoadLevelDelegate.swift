/**
 The `LoadLevelDelegate` protocol defines a set of methods that must be implemented
 by any class that can load a new level.
 */

protocol LoadLevelDelegate: AnyObject {
    func loadLevel(levelName: String)
}
