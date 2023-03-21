/**
 The `PegType` enumeration contains all the types of `Peg` that can be used in the game.
 */

import CoreData

enum PegType: Equatable {
    case compulsary,
         optional,
         confusement,
         zombie,
         spooky,
         kaboom

    static let pegTypeToAssetNameMap = [compulsary: "peg-orange",
                                          optional: "peg-blue",
                                       confusement: "peg-red",
                                            zombie: "peg-yellow",
                                            spooky: "peg-grey",
                                            kaboom: "peg-green"]

    static let pegTypeToHitAssetNameMap = [compulsary: "peg-orange-glow",
                                             optional: "peg-blue-glow",
                                          confusement: "peg-red-glow",
                                               zombie: "peg-yellow-glow",
                                               spooky: "peg-grey-glow",
                                               kaboom: "peg-green-glow"]

    static let pegTypeToTypeNameMap = [compulsary: "compulsary",
                                         optional: "optional",
                                      confusement: "confusement",
                                           zombie: "zombie",
                                           spooky: "spooky",
                                           kaboom: "kaboom"]

    static let typeNameToPegTypeMap = ["compulsary": compulsary,
                                       "optional": optional,
                                       "confusement": confusement,
                                       "zombie": zombie,
                                       "spooky": spooky,
                                       "kaboom": kaboom]

    static let pegTypeToScoreMap = [compulsary: 100,
                                      optional: 10,
                                   confusement: 10,
                                        zombie: 30,
                                        spooky: 20,
                                        kaboom: 30]

    var assetName: String? {
        return PegType.pegTypeToAssetNameMap[self]
    }
}

// MARK: +ToDataAble
extension PegType: ToDataAble {
    func toData(context: NSManagedObjectContext) -> NSManagedObject {
        let pegTypeData = PegTypeData(context: context)
        pegTypeData.typeName = PegType.pegTypeToTypeNameMap[self]
        return pegTypeData as NSManagedObject
    }
}

// MARK: FromDataAble
extension PegType: FromDataAble {
    init(data: PegTypeData) throws {
        guard let name = data.typeName,
              let type = PegType.typeNameToPegTypeMap[name] else {
            throw PeggleError.invalidPegTypeError(typeName: data.typeName)
        }
        self = type
    }
}
