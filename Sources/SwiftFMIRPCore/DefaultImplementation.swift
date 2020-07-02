struct DefaultHero: Hero {
   var race: String  = "Random Race"

    var energy: Int = 5
    var lifePoitns: Int = 7

    var weapon: Weapon?  = nil
    var armor: Armor? = nil

}

struct NoArmor: Armor {
    var attack: Int = 0
    var defence: Int = 0
}

struct WoodenStick: Weapon {
    var attack: Int = 2
    var defence: Int = 1
}

class DefaultPlayer: Player {
    var name: String = "Default Player"
    var hero: Hero = DefaultHero()
    var isAlive: Bool  = true
    var positionInMap: (Int, Int) = (0,0)
}

struct DefaultPlayerGenerator: PlayerGenerator {
    var heroGenerator: HeroGenerator
    init(heroGenerator: HeroGenerator) {
        self.heroGenerator = heroGenerator
    }
    
    func generatePlayer(name: String) -> Player {
        let player = DefaultPlayer()
        player.name = name
        player.hero = heroGenerator.getRandom()
        return player
    }
}

struct DefaultHeroGenerator: HeroGenerator {
    func getRandom() -> Hero {
        return DefaultHero()
    }
}

struct DefaultMapGenerator : MapGenerator {
    func generate(players: [Player]) -> Map {
        return DefaultMap(players: players)
    }
}
class DefaultMapTile: MapTile {
    var type: MapTileType
    var state: String
    
    init(type: MapTileType) {
        self.type = type
        state = ""
    }
}

class DefaultMap : Map {
    required init(players: [Player]) {
        self.players = players
    }

    var players: [Player]
    var maze: [[MapTile]] = [
        [DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall),DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall)],
        
        [DefaultMapTile(type: .wall), DefaultMapTile(type: .empty), DefaultMapTile(type: .wall),DefaultMapTile(type: .rock), DefaultMapTile(type: .chest), DefaultMapTile(type: .empty), DefaultMapTile(type: .wall)],
        
        [DefaultMapTile(type: .wall), DefaultMapTile(type: .empty), DefaultMapTile(type: .wall),DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall)],
        
        [DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall),DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall)],
        
        [DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall),DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall)],
        
        [DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall),DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall), DefaultMapTile(type: .wall)]
        
    ]

    func availableMoves(player: Player) -> [PlayerMove] {
        let rowSize = maze[0].count
        let columnSize = maze.count
        var availableMoves: [PlayerMove] = [PlayerMove]()
        if player.positionInMap.0 + 1 < rowSize && maze[player.positionInMap.0 + 1][player.positionInMap.1].type != .wall {
            availableMoves.append(StandartPlayerMove(direction: .right))
        }
       if player.positionInMap.0 - 1 >= 0 && maze[player.positionInMap.0 - 1][player.positionInMap.1].type != .wall {
           availableMoves.append(StandartPlayerMove(direction: .left))
       }
        if player.positionInMap.1 + 1 < columnSize && maze[player.positionInMap.0][player.positionInMap.1 + 1].type != .wall {
            availableMoves.append(StandartPlayerMove(direction: .down))
        }
        if player.positionInMap.1 - 1 >= 0 && maze[player.positionInMap.0][player.positionInMap.1 - 1].type != .wall {
            availableMoves.append(StandartPlayerMove(direction: .up))
        }
        
        return availableMoves
    }

    func move(player: Player, move: PlayerMove) {
        //ТОДО: редуцирай енергията на героя на играча с 1
        if availableMoves(player: player).contains(move) {
            if move.direction == .up {
                player.positionInMap.0 = player.positionInMap.0 - 1
                player.positionInMap.1 = player.positionInMap.1
            } else if move.direction == .down {
                player.positionInMap.0 = player.positionInMap.0 + 1
                player.positionInMap.1 = player.positionInMap.1
            } else if move.direction == .right {
                player.positionInMap.0 = player.positionInMap.0
                player.positionInMap.1 = player.positionInMap.1 + 1
            } else if move.direction == .left {
                player.positionInMap.0 = player.positionInMap.0
                player.positionInMap.1 = player.positionInMap.1 - 1 
            }
        }
    }
    
}

class DefaultFightGenerator : FightGenerator {
    //TBD
}

class DefaultEquipmentGenerator : EquipmentGenerator {
    var allArmors: [Armor]
    
    var allWeapons: [Weapon]
    
    init() {
        allArmors = [NoArmor()]
        allWeapons = [WoodenStick()]
    }
}

class DefaultMapRenderer: MapRenderer {
    func render(map: Map) {
        for row in map.maze {
            self.renderMapRow(row: row)
        }
        
        renderMapLegend()
    }
    
    private func renderMapRow(row: [MapTile]) {
        var r = ""
        for tile in row {
            switch tile.type {
            case .chest:
                r += "📦"
            case .rock:
                r += "🗿"
            case .teleport:
                r += "💿"
            case .empty:
                r += "  "
            case .wall:
                r += "🧱"
            default:
                //empty
                r += " "
            }
        }
        
        print("\(r)")
    }
    
    private func renderMapLegend() {
        print("No map legend, yet!")
    }
}
