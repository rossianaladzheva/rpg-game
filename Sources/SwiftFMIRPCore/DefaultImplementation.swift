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
    static func == (lhs: DefaultMapTile, rhs: DefaultMapTile) -> Bool {
        return lhs.type == rhs.type && (lhs.position.0 == rhs.position.0) && (lhs.position.1 == rhs.position.1)
    }
    
    var type: MapTileType
    var state: String
    var position: (Int,Int)
    
    init(type: MapTileType, position: (Int,Int)) {
        self.type = type
        self.position = position
        state = ""
    }
}

class DefaultMap : Map {
    required init(players: [Player]) {
        self.players = players
        self.maze = generateMaze(for: players)
    }
    
    var players: [Player]
    var maze = [[DefaultMapTile]]()
    
    private func generateMaze(for players: [Player]) -> [[DefaultMapTile]] {
        //матрицата ни ще е 6х6
        var resultMaze: [[DefaultMapTile]] = [[DefaultMapTile]]()
        var mazeRow: [DefaultMapTile] = [DefaultMapTile]()
        var mapTileType: [MapTileType] = [MapTileType]()
        let tileTypeWithoutPlayer: [MapTileType] = [.chest, .empty, .empty, .empty, .empty, .wall, .teleport, .empty, .wall, .empty, .chest, .teleport, .teleport, .empty, .empty, .chest, .empty, .rock, .wall, .empty, .empty, .empty, .chest, .teleport, .empty, .empty, .empty, .teleport, .empty, .wall, .rock, .empty, .teleport, .empty, .wall, .rock]
        let playerTiles: [MapTileType] = [.player1, .player2, .player3, .player4]
        
        //взимаме си случайни плочки на брой 36 - бройката на играчите
        for i in 0...((tileTypeWithoutPlayer.count - 1) - players.count) {
            mapTileType.append(tileTypeWithoutPlayer[i])
        }
        
        //добавяме и плочките на играчите, които имаме
        for i in 0...players.count - 1 {
            mapTileType.append(playerTiles[i])
        }
        
        //разбъркваме, защото иначе, последните 2-4 плочки в матрицата ще са винаги тези на играчите
        mapTileType.shuffle()

        var emojiArrayIndex = 0
        for row in 0...5 {
            for column in 0...5 {
                mazeRow.append(DefaultMapTile(type: mapTileType[emojiArrayIndex], position: (row, column)))
                emojiArrayIndex += 1
            }
            resultMaze.append(mazeRow)
            mazeRow = [DefaultMapTile]()
        }
        
        return resultMaze
    }
    
    func getCurrentPosition(of player: Player) -> DefaultMapTile {
        var currentPlayerPosition = DefaultMapTile(type: .empty, position: (0,0))
        for column in 0..<maze.count {
            for row in 0..<maze[column].count {
                switch maze[row][column].type {
                case .player1:
                    if player.name == "Player #1" {
                        currentPlayerPosition = DefaultMapTile(type: .player1, position: (row,column))
                    }
                case .player2:
                    if player.name == "Player #2" {
                        currentPlayerPosition = DefaultMapTile(type: .player2, position: (row,column))
                    }
                case .player3:
                    if player.name == "Player #3" {
                        currentPlayerPosition = DefaultMapTile(type: .player3, position: (row,column))
                    }
                case .player4:
                    if player.name == "Player #4" {
                        currentPlayerPosition = DefaultMapTile(type: .player4, position: (row,column))
                    }
                default:
                    break
                }
            }
        }
        return currentPlayerPosition
    }
    
    func availableMoves(player: Player) -> [PlayerMove] {
        var availableMoves: [PlayerMove] = [PlayerMove]()
        let currentPlayerPosition = getCurrentPosition(of: player)
        
        for column in 0..<maze.count {
            for row in 0..<maze[column].count {
                if maze[row][column] == currentPlayerPosition {
                    if  row-1 >= 0 {
                        if maze[row-1][column].type == .empty || maze[row-1][column].type == .teleport {
                            availableMoves.append(StandartPlayerMove(direction: .up))
                        }
                    }
                    if  row+1 < maze.count {
                        if maze[row+1][column].type == .empty || maze[row+1][column].type == .teleport {
                            availableMoves.append(StandartPlayerMove(direction: .down))
                        }
                    }
                    if column-1 >= 0 {
                        if maze[row][column-1].type == .empty || maze[row][column-1].type == .teleport {
                            availableMoves.append(StandartPlayerMove(direction: .left))
                        }
                    }
                    if column+1 < maze[0].count {
                        if maze[row][column+1].type == .empty || maze[row][column+1].type == .teleport {
                            availableMoves.append(StandartPlayerMove(direction: .right))
                        }
                    } 
                }
            }
        }
        return availableMoves
    }
    
    func move(player: Player, move: PlayerMove) {
        
        let playerPosition = getCurrentPosition(of: player)
       for column in 0..<maze.count {
        for row in 0..<maze[column].count {
            if maze[row][column] == playerPosition {
            switch move.direction {
                case .down:
                    availableMoves(player: player).forEach { (availableMove) in
                        if availableMove.direction == .down {
                            let positionDown = maze[row + 1][column]
                            swapTiles(tile1: playerPosition, tile2: positionDown)
                        }
                    }
                case .up:
                    availableMoves(player: player).forEach { (availableMove) in
                        if availableMove.direction == .up {
                            let positionUp = maze[row - 1][column]
                            swapTiles(tile1: playerPosition, tile2: positionUp)
                        }
                    }
                case .right:
                    availableMoves(player: player).forEach { (availableMove) in
                        if availableMove.direction == .right {
                            let positionRight = maze[row][column + 1]
                            swapTiles(tile1: playerPosition, tile2: positionRight)
                        }
                    }
                case .left:
                    availableMoves(player: player).forEach { (availableMove) in
                        if availableMove.direction == .left {
                            let positionLeft = maze[row][column - 1]
                            swapTiles(tile1: playerPosition, tile2: positionLeft)
                        }
                    }
                }
            }
            }
        }
      //ТОДО: редуцирай енергията на героя на играча с 1
    }
        
    private func swapTiles(tile1: DefaultMapTile, tile2: DefaultMapTile) {
        //Problem: it moves the player emoji but doesn't empty the other one
        swap(&tile1.position, &tile2.position)
        swap(&tile1.type, &tile2.type)
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
    
    private func renderMapRow(row: [DefaultMapTile]) {
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
            case .player1:
                r += "👮"
            case .player2:
                r += "👨‍🌾"
            case .player3:
                r += "👨‍⚕️"
            case .player4:
                r += "👩‍🚒"
            default:
                //empty
                r += "  "
            }
        }
        
        print("\(r)")
    }
    
    private func renderMapLegend() {
        print("No map legend, yet!")
    }
}
