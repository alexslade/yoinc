Meteor.startup ->
  @Game.init()

@Game = new ReactiveObject
  profitPrice: 10

  yos: 0
  cash: 0
  showCash: false
  showProfitButton: false
  baseYo: 1

  yoGen: [
    new ReactiveObject
      owned: 0
      bought: 0
      name: "iPhone"
      description: "Sends 10 yo per second"
      cost: -> 400 + 200 * Math.pow(1.2, @bought)
      benefit: ['yo', 10]
    new ReactiveObject
      owned: 0
      bought: 0
      name: "Hipster"
      description: "Buys 1 iPhone every second"
      cost: -> 8000 + 1000 * Math.pow(1.5, @bought)
      benefit: ['iPhone', 1]
    new ReactiveObject
      owned: 0
      bought: 0
      name: "TechHub"
      description: "Creates 1 Hipster every second"
      cost: -> 2500000 + 100 * @bought * @bought
      benefit: ['Hipster', 1]
    new ReactiveObject
      owned: 0
      bought: 0
      name: "VC"
      description: "Forms 1 TechHub every second"
      cost: -> 80000000 + 100 * @bought * @bought
      benefit: ['TechHub', 1]
    new ReactiveObject
      owned: 0
      bought: 0
      name: "HedgeFund"
      description: "Spawns 1 VC every second"
      cost: -> 43000000000 + 100 * @bought * @bought
      benefit: ['VC', 1]
  ]

  cashGen: [
    new ReactiveObject
      owned: 0
      bought: 0
      name: "Blog"
      description: "Converts yos into profit"
      cost: -> 200 + 200 * Math.pow(1.2, @bought)
      benefit: ['cash', 5]
    new ReactiveObject
      owned: 0
      bought: 0
      name: "Growth hacker"
      description: "Sets up a new Blog every second"
      cost: -> 3500 + 2000 * Math.pow(1.5, @bought)
      benefit: ['Blog', 1]
  ]

  upgrades: [
    new ReactiveObject
      active: false
      name: "Double Tap"
      description: "Send two Yos at once"
      cost: 10
      benefit: ["yo", 2]
    new ReactiveObject
      active: false
      name: "Networking"
      description: "Sell twice as many Yos per click"
      cost: 50
      benefit: ["sell", 2]
    new ReactiveObject
      active: false
      name: "Special Gloves"
      description: "Waste nothing. 5x Yos per click."
      cost: 100
      benefit: ["yo", 5]
    new ReactiveObject
      active: false
      name: "Internet famous"
      description: "People want your Yos. Sell 3x per click."
      cost: 1000
      benefit: ["sell", 3]

  ]

  yoMultiplier: ->
    upgrades = _.select Game.upgrades, (o)->
      o.active && o.benefit[0] == "yo"
    _.reduce(upgrades, ((total, n) -> total * n.benefit[1]) , 1)

  sellMultiplier: ->
    upgrades = _.select Game.upgrades, (o)->
      o.active && o.benefit[0] == "sell"
    _.reduce(upgrades, ((total, n) -> total * n.benefit[1]) , 1)

  init: ->
    console.log "Game init"
    @_setupFPSMeter()
    @_startGameLoop()

  _startGameLoop: ->
    boundUpdate = (=> @_update())
    setInterval(boundUpdate, 1000/3)

  _setupFPSMeter: ->
    @meter = new FPSMeter
      bottom: "5px"
      top: null
  _tick: ->
    @meter.tick()
  _fps: ->
    @meter.fps

  _update: ->
    @_tick()
    @oldTime = @time || performance.now()
    @time = performance.now()
    delta = (@time - @oldTime)/1000

    for gen in Game.yoGen
      if gen.benefit[0] == 'yo'
        Game.yos += delta * gen.owned * gen.benefit[1]
      else
        gen2 = _.find(Game.yoGen, ((o) -> o.name == gen.benefit[0]))
        gen2.owned += delta * gen.benefit[1] * gen.owned

    for gen in Game.cashGen
      if gen.benefit[0] == 'cash'
        yosToSell = Math.min(delta * gen.owned * gen.benefit[1], Game.yos)
        Game.yos -= yosToSell
        Game.cash += yosToSell / Game.profitPrice
      else
        gen2 = _.find(Game.cashGen, ((o) -> o.name == gen.benefit[0]))
        gen2.owned += delta * gen.benefit[1] * gen.owned

    # yoGenerators = _.filter(Game.yoGen, ((o) -> o.benefit[0] == 'yo'))
    # yos = _.reduce(yoGenerators, ((total, o) -> o.owned * o.benefit[1]), 0)

    # # Game.phones += delta * Game.hipsters
    # # Game.hipsters *= 1.1


Template.stats.helpers
  yoCount: -> Game.yos
  yoMultiplier: -> Game.yoMultiplier()
  profitPrice: -> Game.profitPrice * Game.sellMultiplier()
  profitMade: -> Game.sellMultiplier()
  cash: -> Game.cash
  showCash: -> Game.showCash
  showProfitButton: -> Game.showProfitButton


Template.stats.events
  'click #yoButton': (e) ->
    Game.yos += Game.yoMultiplier()
    if Game.yos >= Game.profitPrice
      Game.showProfitButton = true
  'click #profitButton': (e) ->
    yosToSell = Math.min(Game.yos, Game.profitPrice * Game.sellMultiplier())
    Game.yos -= yosToSell
    Game.cash += (yosToSell / (Game.profitPrice * Game.sellMultiplier())) * Game.sellMultiplier()
    Game.showCash = true

Template.actions.events
  'click #buyPhone': (e) ->
    if Game.cash >= Game.phonePrice
      Game.phones += 1
      Game.cash -= Game.phonePrice
      Game.showPhones = true
  'click #buyHipster': (e) ->
    if Game.cash >= Game.hipsterPrice
      Game.hipsters += 1
      Game.cash -= Game.hipsterPrice
      Game.showHipsters = true

  'click #upgrades .button': (e) ->
    if Game.cash >= this.cost
      Game.cash -= this.cost
      this.active = true

  'click #yoGen .button': (e) ->
    if Game.cash >= this.cost()
      Game.cash -= this.cost()
      this.owned += 1
      this.bought += 1

  'click #cashGen .button': (e) ->
    if Game.cash >= this.cost()
      Game.cash -= this.cost()
      this.owned += 1
      this.bought += 1



Template.actions.helpers

  showBuyPhone: -> Game.showBuyPhone
  showBuyHipster: -> Game.showBuyHipster
  phones: -> Game.phones
  hipsters: -> Game.hipsters

  showPhones: -> Game.showPhones
  showHipsters: -> Game.showHipsters
  upgrades: ->
    _.filter Game.upgrades, (u, i) ->
      if i == 0
        return true
      u.active || (u.cost / 2 < Game.cash)
  yoGen: ->
    _.filter Game.yoGen, (u, i) ->
      if i == 0
        return true
      Game.yoGen[i-1].owned > 0
  cashGen: ->
    _.filter Game.cashGen, (u, i) ->
      if i == 0
        return true
      Game.yoGen[i-1].owned > 0
