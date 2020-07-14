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
        //матрицата на картата е 6х6
        var resultMaze: [[DefaultMapTile]] = [[DefaultMapTile]]()
        var mazeRow: [DefaultMapTile] = [DefaultMapTile]()
        var mapTileType: [MapTileType] = [MapTileType]()
        let tileTypeWithoutPlayer: [MapTileType] = [.chest, .empty, .teleport, .empty, .empty, .empty, .wall, .teleport, .empty, .wall, .empty, .chest, .teleport, .teleport, .empty, .empty, .chest, .empty, .rock, .wall, .empty, .empty, .empty, .chest, .teleport, .empty, .empty, .empty, .teleport, .empty, .wall, .rock, .empty, .empty, .wall, .rock]
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
    
   private func getCurrentPosition(of player: Player) -> DefaultMapTile {
        var currentPlayerPosition = DefaultMapTile(type: .empty, position: (0,0))
        for row in maze {
            for tile in row {
                switch tile.type {
                case .player1:
                    if player.name == "Player #1" {
                        currentPlayerPosition = tile
                    }
                case .player2:
                    if player.name == "Player #2" {
                        currentPlayerPosition = tile
                    }
                case .player3:
                    if player.name == "Player #3" {
                        currentPlayerPosition = tile
                    }
                case .player4:
                    if player.name == "Player #4" {
                        currentPlayerPosition = tile
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
                        if maze[row-1][column].type != .rock && maze[row-1][column].type != .wall && maze[row-1][column].type != .openChest {
                            availableMoves.append(StandartPlayerMove(direction: .up))
                        }
                    }
                    if  row+1 < maze.count {
                        if maze[row+1][column].type != .rock && maze[row+1][column].type != .wall && maze[row+1][column].type != .openChest {
                            availableMoves.append(StandartPlayerMove(direction: .down))
                        }
                    }
                    if column-1 >= 0 {
                        if maze[row][column-1].type != .rock && maze[row][column-1].type != .wall && maze[row][column-1].type != .openChest {
                            availableMoves.append(StandartPlayerMove(direction: .left))
                        }
                    }
                    if column+1 < maze[0].count {
                        if maze[row][column+1].type != .rock && maze[row][column+1].type != .wall && maze[row][column+1].type != .openChest {
                            availableMoves.append(StandartPlayerMove(direction: .right))
                        }
                    } 
                }
            }
        }
        return availableMoves
    }
    
   private func executeMove(for player: Player, on tile: DefaultMapTile) {
        let playerPosition = getCurrentPosition(of: player)
        switch tile.type {
        case .teleport:
            teleport(player: player, from: tile)
        case .chest:
            tile.type = .openChest
            print("Отворихте съндъка и придобихте ново оръжие 🗡")
            //Armour functionality TBD
        case .empty:
            swap(&playerPosition.type, &tile.type)
            playerPosition.position = tile.position
        case .player1, .player2, .player3, .player4:
            print("Започнахте битка.")
            //Fight functionality TBD
        default:
            break
        }
    }
    
    private func teleport(player: Player, from nearbyTeleport: DefaultMapTile) {
        let playerPosition = getCurrentPosition(of: player)

        for row in maze {
            for tile in row {
                //логиката е играчът да се телепортира до някой друг телепорт, след което и двата телепорта изчезват
                if tile.type == .teleport && tile.position != nearbyTeleport.position {
                    tile.type = .empty
                    swap(&playerPosition.type, &tile.type)
                    playerPosition.position = tile.position
                    nearbyTeleport.type = .empty
                    return
                }
            }
        }
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
                         executeMove(for: player, on: positionDown)
                        }
                    }
                case .up:
                    availableMoves(player: player).forEach { (availableMove) in
                        if availableMove.direction == .up {
                            let positionUp = maze[row - 1][column]
                            executeMove(for: player, on: positionUp)
                        }
                    }
                case .right:
                    availableMoves(player: player).forEach { (availableMove) in
                        if availableMove.direction == .right {
                            let positionRight = maze[row][column + 1]
                            executeMove(for: player, on: positionRight)
                        }
                    }
                case .left:
                    availableMoves(player: player).forEach { (availableMove) in
                        if availableMove.direction == .left {
                            let positionLeft = maze[row][column - 1]
                            executeMove(for: player, on: positionLeft)
                        }
                    }
                }
            }
            }
        }
      //ТОДО: редуцирай енергията на героя на играча с 1
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
    }
    
    private func renderMapRow(row: [DefaultMapTile]) {
        var r = ""
        for tile in row {
            switch tile.type {
            case .chest:
                r += "📦"
            case .openChest:
                r += "🗃"
            case .rock:
                r += "🗿"
            case .teleport:
                r += "💿"
            case .empty:
                r += "  "
            case .wall:
                r += "🧱"
            case .player1:
                r += "🦸‍♂️"
            case .player2:
                r += "🦹‍♀️"
            case .player3:
                r += "🧝‍♀️"
            case .player4:
                r += "🧙‍♂️"
            }
        }
        
        print("\(r)")
    }
    
    func renderMapLegend() {
        print("ЛЕГЕНДА")
        print("Полета 'скала̀: 🗿' и 'стена: 🧱' - няма позволен ход към полета от тези типове")
        print("Поле 'телепорт: 💿' - телепортира ви на друго поле тип 'телепорт', след което двата телепорта изчезват и не могат да бъдат използвани отново")
        print("Поле 'съндък: 📦' - ако се направи ход към това поле, съндъкът се отваря и играчът получава оръжие")
        print("Поле 'oтворен съндък: 🗃' - след като полето 'съндък' е било достъпено и отворено, вече няма позволен ход към това поле.")
        print("Поле 'играч: 🦸‍♂️,🦹‍♀️,🧝‍♀️,🧙‍♂️' - полетата на активните играчи - ако се направи ход към друг играч, започва се битка.")
        print("Поле 'празно:  ' - това поле дава право на движение - можете да придвижите играча си на него")
    }
}
