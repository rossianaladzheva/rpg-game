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
        return lhs.type == rhs.type
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
        var mapTileType: [MapTileType] = [MapTileType]()
        let tileTypeWithoutPlayer: [MapTileType] = [.chest,.empty,.rock,.teleport,.wall]
        let playerTiles: [MapTileType] = [.player1, .player2, .player3, .player4]
        
        //взимаме си случайни плочки на брой 36 - бройката на играчите
        for _ in 0...35 - (players.count - 1)  {
            mapTileType.append(tileTypeWithoutPlayer.randomElement()!)
        }
        
        //добавяме и плочките на играчите, които имаме
        for i in 0...players.count - 1 {
            mapTileType.append(playerTiles[i])
        }
        
        //разбъркваме отново, защото иначе, последните 2-4 плочки ще са винаги на играчите
        mapTileType.shuffle()
        
        var rowMaze: [DefaultMapTile] = [DefaultMapTile]()
        for j in 1...36 {
            rowMaze.append(DefaultMapTile(type: mapTileType[j], position: (0,j)))
            if j % 6 == 0 {
                resultMaze.append(rowMaze)
                rowMaze = [DefaultMapTile]()
            }
        }
        
        return resultMaze
    }
    
    func getCurrentPosition(of player: Player) -> DefaultMapTile {
        var currentPlayerPosition = DefaultMapTile(type: .empty, position: (0,0))
        for i in 0..<maze.count {
                  for j in 0..<maze[i].count {
                      switch maze[i][j].type {
                      case .player1:
                          if player.name == "Player #1" {
                              currentPlayerPosition = DefaultMapTile(type: .player1, position: (i,j))
                          }
                      case .player2:
                          if player.name == "Player #2" {
                              currentPlayerPosition = DefaultMapTile(type: .player1, position: (i,j))
                          }
                      case .player3:
                          if player.name == "Player #3" {
                              currentPlayerPosition = DefaultMapTile(type: .player1, position: (i,j))
                          }
                      case .player4:
                          if player.name == "Player #4" {
                              currentPlayerPosition = DefaultMapTile(type: .player1, position: (i,j))
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
        
        for i in 0..<maze.count {
            for j in 0..<maze[i].count {
                if maze[i][j] == currentPlayerPosition {
                    if  i-1 >= 0 {
                        if maze[i-1][j].type == .empty || maze[i-1][j].type == .teleport {
                            availableMoves.append(StandartPlayerMove(direction: .up))
                        }
                    }
                    if  i+1 < maze.count {
                        if maze[i+1][j].type == .empty || maze[i+1][j].type == .teleport {
                            availableMoves.append(StandartPlayerMove(direction: .down))
                        }
                    }
                    if j-1 >= 0 {
                        if maze[i][j-1].type == .empty || maze[i][j-1].type == .teleport {
                            availableMoves.append(StandartPlayerMove(direction: .left))
                        }
                    }
                    if j+1 < maze[0].count {
                        if maze[i][j+1].type == .empty || maze[i][j+1].type == .teleport {
                            availableMoves.append(StandartPlayerMove(direction: .right))
                        }
                    } 
                }
            }
        }
        return availableMoves
    }
    
    func move(player: Player, move: PlayerMove) {
        //ТОДО: редуцирай енергията на героя на играча с 1
        //        availableMoves(player: player).forEach { (move) in
        //            if move.direction == .up {
        //               // player.positionInMap.0 = player.positionInMap.0 - 1
        //               // player.positionInMap.1 = player.positionInMap.1
        //                maze[player.positionInMap.0 - 1][player.positionInMap.1].type = .player
        //                maze[player.positionInMap.0][player.positionInMap.1].type = .empty
        //            } else if move.direction == .down {
        //              //  player.positionInMap.0 = player.positionInMap.0 + 1
        //              //  player.positionInMap.1 = player.positionInMap.1
        //                maze[player.positionInMap.0 + 1][player.positionInMap.1].type = .player
        //                maze[player.positionInMap.0][player.positionInMap.1].type = .empty
        //            } else if move.direction == .right {
        //               // player.positionInMap.0 = player.positionInMap.0
        //               // player.positionInMap.1 = player.positionInMap.1 + 1
        //                maze[player.positionInMap.0][player.positionInMap.1 + 1].type = .player
        //                maze[player.positionInMap.0][player.positionInMap.1].type = .empty
        //            } else if move.direction == .left {
        //               // player.positionInMap.0 = player.positionInMap.0
        //               // player.positionInMap.1 = player.positionInMap.1 - 1
        //                maze[player.positionInMap.0 - 1][player.positionInMap.1 - 1].type = .player
        //                maze[player.positionInMap.0][player.positionInMap.1].type = .empty
        //            }
        //    }
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
