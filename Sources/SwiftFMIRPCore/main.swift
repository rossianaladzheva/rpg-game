var mapGenerator = DefaultMapGenerator()
var playerGenerator = DefaultPlayerGenerator(heroGenerator: DefaultHeroGenerator())
var figthGenerator = DefaultFightGenerator()
var equipmentGenerator = DefaultEquipmentGenerator()
var mapRendered = DefaultMapRenderer()
var game = Game(mapGenerator: mapGenerator, playerGenerator: playerGenerator, mapRenderer: mapRendered)

game.run()
