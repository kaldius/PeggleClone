import CoreData

enum GameMode: CaseIterable {
    case normal,
         timeAttack,
         siam

    static let gameModeToModeNameMap = [normal: "Normal",
                                timeAttack: "Time Attack",
                                      siam: "Siam"]

    static let modeNameToGameModeMap = ["Normal": normal,
                                    "Time Attack": timeAttack,
                                    "Siam": siam]
}

// MARK: +ToDataAble
extension GameMode: ToDataAble {
    func toData(context: NSManagedObjectContext) -> NSManagedObject {
        let gameModeData = GameModeData(context: context)
        gameModeData.modeName = GameMode.gameModeToModeNameMap[self]
        return gameModeData as NSManagedObject
    }
}

// MARK: FromDataAble
extension GameMode: FromDataAble {
    init(data: GameModeData) throws {
        guard let name = data.modeName,
              let modeName = GameMode.modeNameToGameModeMap[name] else {
            throw PeggleError.invalidGameModeError(modeName: data.modeName)
        }
        self = modeName
    }
}
