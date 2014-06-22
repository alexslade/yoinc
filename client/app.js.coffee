Meteor.startup ->
  @Game.init()

@Game = new ReactiveObject
  profitPrice: 1
  phonePrice: 1
  hipsterPrice: 100

  yos: 0
  cash: 0
  showCash: true
  showProfitButton: true
  phones: 0
  showPhones: true
  showBuyPhone: true
  hipsters: 0
  showHipsters: true
  showBuyHipster: true

  baseYo: 1

  yoGen: [
    new ReactiveObject
      owned: 0
      name: "Phone"
      cost: -> 1 * @owned * @owned
      benefit: ['yo', 1]
    new ReactiveObject
      owned: 0
      name: "Hipster"
      cost: -> 100 * @owned * @owned
      benefit: ['Phone', 1]
    new ReactiveObject
      owned: 0
      name: "TechHub"
      cost: -> 100 * @owned * @owned
      benefit: ['Hipster', 1]
    new ReactiveObject
      owned: 0
      name: "VC"
      cost: -> 100 * @owned * @owned
      benefit: ['TechHub', 1]
    new ReactiveObject
      owned: 0
      name: "HedgeFund"
      cost: -> 100 * @owned * @owned
      benefit: ['VC', 1]
  ]

  upgrades: [
    new ReactiveObject
      active: false
      name: "Double Tap"
      cost: 200
      benefit:
        yoClick: 2
  ]

  yoMultiplier: ->
    upgrades = _.select(Game.upgrades, (o)-> o.active)
    _.reduce(upgrades, ((total, n) -> total * n.benefit.yoClick) , 1)

  init: ->
    console.log "Game init"
    @_setupFPSMeter()
    @_startGameLoop()

  _startGameLoop: ->
    boundUpdate = (=> @_update())
    setInterval(boundUpdate, 1000/60)

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

    # yoGenerators = _.filter(Game.yoGen, ((o) -> o.benefit[0] == 'yo'))
    # yos = _.reduce(yoGenerators, ((total, o) -> o.owned * o.benefit[1]), 0)

    # # Game.phones += delta * Game.hipsters
    # # Game.hipsters *= 1.1


Template.stats.helpers
  yoCount: -> Game.yos
  cash: -> Game.cash
  showCash: -> Game.showCash
  showProfitButton: -> Game.showProfitButton
Template.stats.events
  'click #yoButton': (e) ->
    Game.yos += Game.yoMultiplier()
    if Game.yos >= Game.profitPrice
      Game.showProfitButton = true
  'click #profitButton': (e) ->
    if Game.yos >= Game.profitPrice
      Game.yos -= Game.profitPrice
      Game.cash += 1
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

  'click #upgrades button': (e) ->
    if Game.cash >= this.cost
      Game.cash -= this.cost
      this.active = true

  'click #yoGen button': (e) ->
    this.owned += 1



Template.actions.helpers

  showBuyPhone: -> Game.showBuyPhone
  showBuyHipster: -> Game.showBuyHipster
  phones: -> Game.phones
  hipsters: -> Game.hipsters

  showPhones: -> Game.showPhones
  showHipsters: -> Game.showHipsters
  upgrades: -> Game.upgrades
  yoGen: -> Game.yoGen
