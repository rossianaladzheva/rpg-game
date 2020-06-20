protocol Player {
    var name: String {get set}
    var hero: Hero {get set}
    var isAlive: Bool {get set}
    var positionInMap: (Int, Int) {get set}
}

protocol PlayerGenerator {
    init(heroGenerator: HeroGenerator)
    func generatePlayer(name: String) -> Player
}
