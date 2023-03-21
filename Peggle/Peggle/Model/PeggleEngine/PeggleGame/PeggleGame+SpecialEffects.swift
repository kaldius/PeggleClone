import CoreGraphics

extension PeggleGame {
    func checkZombiePeg(body1Id: ObjectIdentifier, body2Id: ObjectIdentifier) {
        if isBall(id: body1Id) && isZombiePeg(id: body2Id) {
            turnPegIntoBall(id: body2Id)
        }
        if isZombiePeg(id: body1Id) && isBall(id: body2Id) {
            turnPegIntoBall(id: body1Id)
        }
    }

    func checkSpookyPeg(body1Id: ObjectIdentifier, body2Id: ObjectIdentifier) {
        if isBall(id: body1Id) && isSpookyPeg(id: body2Id) {
            guard let peg = idToPegMap[body2Id], !peg.gotHit else { return }
            guard let ball = idToBallMap[body1Id] else { return }
            idToBallMap[body1Id]?.extraLife += 1
            guard let newBall = idToBallMap[body1Id] else { return }
            postBallMovedNotification(beforeBall: ball, afterBall: newBall)
        }
        if isSpookyPeg(id: body1Id) && isBall(id: body2Id) {
            guard let peg = idToPegMap[body1Id], !peg.gotHit else { return }
            guard let ball = idToBallMap[body2Id] else { return }
            idToBallMap[body2Id]?.extraLife += 1
            guard let newBall = idToBallMap[body2Id] else { return }
            postBallMovedNotification(beforeBall: ball, afterBall: newBall)
        }
    }

    func checkKaboomPeg(body1Id: ObjectIdentifier, body2Id: ObjectIdentifier) {
        if isBall(id: body1Id) && isKaboomPeg(id: body2Id) {
            kaboom(id: body2Id)
        }
        if isKaboomPeg(id: body1Id) && isBall(id: body2Id) {
            kaboom(id: body1Id)
        }
    }

    func checkConfusementPeg(body1Id: ObjectIdentifier, body2Id: ObjectIdentifier) {
        if isBall(id: body1Id) && isConfusementPeg(id: body2Id) ||
            isConfusementPeg(id: body1Id) && isBall(id: body2Id) {
            try? flipAlongVerticalAxis()
            try? flipAlongHorizontalAxis()
        }
    }

    func kaboom(id: ObjectIdentifier) {
        guard let kaboomPeg = idToPegMap[id] else { return }
        for id in idOfPegsInRadius(center: kaboomPeg.center, radius: PeggleGame.DEFAULTKABOOMRADIUS) {
            numPegsHitThisRound += 1
            forcefullyRemove(id: id)
        }
    }

    func isConfusementPeg(id: ObjectIdentifier) -> Bool {
        guard let peg = idToPegMap[id] else { return false }
        return peg.type == PegType.confusement
    }

    func isZombiePeg(id: ObjectIdentifier) -> Bool {
        guard let peg = idToPegMap[id] else { return false }
        return peg.type == PegType.zombie
    }

    func isSpookyPeg(id: ObjectIdentifier) -> Bool {
        guard let peg = idToPegMap[id] else { return false }
        return peg.type == PegType.spooky
    }

    func isKaboomPeg(id: ObjectIdentifier) -> Bool {
        guard let peg = idToPegMap[id] else { return false }
        return peg.type == PegType.kaboom
    }

    func flipAlongHorizontalAxis() throws {
        let centerValue = (area.yMax - area.yMin) / 2
        for (id, peg) in idToPegMap {
            let distanceFromCenterHorizontalLine = centerValue - peg.center.dy
            var newPeg = peg
            newPeg.center.dy = centerValue + distanceFromCenterHorizontalLine
            removePeg(id: id)
            try add(peg: newPeg)
        }
        for (id, block) in idToBlockMap {
            let distanceFromCenterHorizontalLine = centerValue - block.center.dy
            var newBlock = block
            let newCenter = CGVector(dx: block.center.dx, dy: centerValue + distanceFromCenterHorizontalLine)
            newBlock.translate(to: newCenter)
            removeBlock(id: id)
            try add(block: newBlock)
        }
    }

    func flipAlongVerticalAxis() throws {
        let centerValue = (area.xMax - area.xMin) / 2
        for (id, peg) in idToPegMap {
            let distanceFromCenterHorizontalLine = centerValue - peg.center.dx
            var newPeg = peg
            newPeg.center.dx = centerValue + distanceFromCenterHorizontalLine
            removePeg(id: id)
            try add(peg: newPeg)
        }
        for (id, block) in idToBlockMap {
            let distanceFromCenterHorizontalLine = centerValue - block.center.dx
            var newBlock = block
            let newCenter = CGVector(dx: centerValue + distanceFromCenterHorizontalLine, dy: block.center.dy)
            newBlock.translate(to: newCenter)
            removeBlock(id: id)
            try add(block: newBlock)
        }
    }
}
