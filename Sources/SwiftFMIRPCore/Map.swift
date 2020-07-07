protocol Map {
    init(players: [Player])
    var players: [Player] {get}
    var maze: [[MapTile]] {get}

    func availableMoves(player: Player) -> [PlayerMove]
    func move(player: Player, move: PlayerMove)
}

protocol MapRenderer {
    func render(map:Map)
}

protocol PlayerMove {
    var direction: MapMoveDirection {get set}
    
    var friendlyCommandName: String {get set} 
}

class StandartPlayerMove: PlayerMove {
    var direction: MapMoveDirection
    
    var friendlyCommandName: String
    
    init(direction: MapMoveDirection) {
        self.direction = direction
        switch self.direction {
        case .up:
            friendlyCommandName = "up"
        case .down:
            friendlyCommandName = "down"
        case .left:
            friendlyCommandName = "left"
        case .right:
            friendlyCommandName = "right"
        }
    }
}

extension PlayerMove {
    var allMoves: [PlayerMove] {
        return [
        StandartPlayerMove(direction: .up),
        StandartPlayerMove(direction: .down),
        StandartPlayerMove(direction: .left),
        StandartPlayerMove(direction: .right)
        ]
    }
}

enum MapMoveDirection {
    case up
    case down
    case left
    case right
}

protocol MapTile {
    var type: MapTileType {get set}
    var state: String {get set}
}

enum MapTileType: CaseIterable {
    case empty
    case chest
    case wall
    case teleport
    case rock
    case player1
    case player2
    case player3
    case player4
}


protocol MapGenerator {
    func generate(players:[Player]) -> Map
}


