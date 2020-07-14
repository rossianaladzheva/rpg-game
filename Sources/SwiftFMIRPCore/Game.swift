func readLine<T: LosslessStringConvertible>(as type: T.Type) -> T? {
  return readLine().flatMap(type.init(_:))
}

class Game {
    var mapGenerator: MapGenerator
    var playerGenerator: PlayerGenerator
    var mapRenderer: MapRenderer

    init(mapGenerator: MapGenerator, playerGenerator: PlayerGenerator, mapRenderer: MapRenderer) {
        self.mapGenerator = mapGenerator
        self.playerGenerator = playerGenerator
        self.mapRenderer = mapRenderer
    }
    
    //implement main logic
    func run() {
        print("Starting the RPG game...")
        var players:[Player] = []
        var totalPlayers = 0
        repeat {
            print("Моля избере брои играчи (2 - 4): ")
            if let number = readLine(as: Int.self) {
                totalPlayers = number
            } else {
              print("Невалиден вход! Моля, опитай пак.")  
            }
        } while totalPlayers < 2 || totalPlayers > 4

        // 1. Избор на брой играчи. Минимум 2 броя.
        
       print("Вие избрахте \(totalPlayers) играчи. Системата сега ще избере вашите герои.")
       for i in 1...totalPlayers {
           print("Генериране на играч...")
           players.append(playerGenerator.generatePlayer(name: "Player #\(i)"))
       }
       
       
       

        let map = mapGenerator.generate(players: players)
        // 1. Избор на брой играчи. Минимум 2 броя.
        // 1. Генериране на карта с определени брой размери на базата на броя играчи.
        // 1. Докато има повече от един оцелял играч, изпълнявай ходове.
        //     * определи енергията за текущия играч
        //     * Текущия играч се мести по картата докато има енергия. 
        //     * Потребителя контролира това като му се предоставя възможност за действие.
        //     * ако се въведе системна команда като `map` се визуализра картата
        // 1. Следващия играч става текущ.
        
        var currentPlayerIndex = 0
        
        while activePlayers(allPlayers: players).count > 1  {
            if var currentPlayer:Player = players[currentPlayerIndex] as? Player, currentPlayer.isAlive {
                let playerNumber = currentPlayerIndex + 1
                let playersAvatars = ["🦸‍♂️","🦹‍♀️","🧝‍♀️","🧙‍♂️"]
                print("Сега е на ход играч №\(playerNumber) - \(currentPlayer.name)" + " с аватар: " + playersAvatars[currentPlayerIndex])
                
                ///команди от играча
                var playerMoveIsNotFinished = true
                repeat {
                    print("Моля въведете команда от възможните: ")
                    let availableMoves = map.availableMoves(player: currentPlayer)
                    var allCommands = ["finish", "map", "legend"]
                    if currentPlayer.isAlive {
                        allCommands.append("seppuku")
                        availableMoves.forEach { (move) in
                            allCommands.append(move.friendlyCommandName)
                        }
                    }
                    print("\(allCommands)")
                    
                    if let command = readLine(as: String.self) {
                        //TODO: провери дали не е от някои от възможните други действия
                        //TODO: ако е от тях изпълни действието
                        if let move = availableMoves.first(where: { (move) -> Bool in
                            move.friendlyCommandName == command
                        }) {
                            //разпозната команда
                            map.move(player: currentPlayer, move: move)
                            playerMoveIsNotFinished = false
                            
                        } else {
                            //иначе, провери за
                            //специални команди
                            switch command {
                            case "finish":
                                playerMoveIsNotFinished = false
                                print("Вашият ход приключи.")
                            case "map":
                                print("Отпечатваме картата:")
                                mapRenderer.render(map: map)
                            case "seppuku":
                                print("Ritual suicide...")
                                currentPlayer.isAlive = false
                                playerMoveIsNotFinished = false
                                print("Вашият ход приключи.")
                            case "legend":
                                mapRenderer.renderMapLegend()
                            default:
                                print("Непозната команда!")
                            }
                        }
                    } else {
                      print("Невалиден вход! Моля, опитай пак.")
                    }
                } while playerMoveIsNotFinished
            }
            
            //минаваме на следващия играч
            currentPlayerIndex += 1
            currentPlayerIndex %= players.count
        }
        let winners = activePlayers(allPlayers: players)
        if winners.count > 0 {
            print("Победител е: \(winners[0].name)")
        } else {
            print("Няма победител :/. Опитайте да изиграете нова игра.")
        }

        print("RPG game has finished.")
        
    }
    
    private func activePlayers(allPlayers: [Player]) -> [Player] {
        return allPlayers.filter { (p) -> Bool in
            p.isAlive
        }
    }
}
