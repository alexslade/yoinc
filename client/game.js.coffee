class @Asset extends ReactiveObject
  owned: 0
  bought: 0
  inflationRate: 1.2
  baseCost: 1
  cost: -> @baseCost * Math.pow(@inflationRate, @bought)
  init: ->
    @super()

@Game = new ReactiveObject
  test: false #true # Test mode
  profitPrice: 5

  yos: 0
  cash: 0
  showCash: false
  showUpgrades: false
  showProfitButton: false
  baseYo: 1
  upgradeInflationRate: 1.2

  yoGen: [
    new Asset
      owned: 0
      baseCost: 600
      name: "iPhone"
      description: "Sends 10 yo per second"
      benefit: ['yo', 10]
    new Asset
      owned: 0
      baseCost: 3000
      name: "Hipster"
      description: "Buys 1 iPhone every second"
      benefit: ['iPhone', 1]
    new Asset
      owned: 0
      baseCost: 250000
      name: "TechHub"
      description: "Creates 1 Hipster every second"
      benefit: ['Hipster', 1]
    new Asset
      owned: 0
      baseCost: 8000000
      name: "VC"
      description: "Forms 1 TechHub every second"
      benefit: ['TechHub', 1]
    new Asset
      owned: 0
      baseCost: 430000000
      name: "HedgeFund"
      description: "Spawns 1 VC every second"
      benefit: ['VC', 1]
  ]

  cashGen: [
    new Asset
      baseCost: 400
      owned: 0
      name: "Blog"
      description: "Converts yos into profit"
      benefit: ['cash', 5]
    new Asset
      baseCost: 3500
      owned: 0
      name: "Growth hacker"
      description: "Sets up a new Blog every second"
      benefit: ['Blog', 1]
    new Asset
      baseCost: 40000
      owned: 0
      name: "Startup"
      description: "Hires 1 growth hacker every second"
      benefit: ['Growth hacker', 1]
    new Asset
      baseCost: 500000
      owned: 0
      name: "Entrepreneur"
      description: "Founds a startup each second"
      benefit: ['Startup', 1]
    new Asset
      baseCost: 6000000
      owned: 0
      name: "YCombinator"
      description: "Spawns an entrepreneur each second"
      benefit: ['Entrepreneur', 1]
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
      description: "Sell 3x as many Yos per click"
      cost: 40
      benefit: ["sell", 3]
    new ReactiveObject
      active: false
      name: "Special Gloves"
      description: "Waste nothing. 10x Yos per click."
      cost: 70
      benefit: ["yo", 10]
    new ReactiveObject
      active: false
      name: "Internet famous"
      description: "People want your Yos. Sell 5x per click."
      cost: 300
      benefit: ["sell", 5]
    new ReactiveObject
      active: false
      name: "Designer News"
      description: "Flat UI! 10x Yos"
      cost: 900
      benefit: ["yo", 10]
    new ReactiveObject
      active: false
      name: "Hacker news"
      description: "You've hit product-market fit. Sell 5x yos."
      cost: 1700
      benefit: ["sell", 5]
    new ReactiveObject
      active: false
      name: "Botnet"
      description: "You'll never get seeded without it. 10x yos."
      cost: 5000
      benefit: ["yo", 10]
  ]

  yoMultiplier: ->
    upgrades = _.select @upgrades, (o)->
      o.active && o.benefit[0] == "yo"
    _.reduce(upgrades, ((total, n) -> total * n.benefit[1]) , 1)

  sellMultiplier: ->
    upgrades = _.select @upgrades, (o)->
      o.active && o.benefit[0] == "sell"
    _.reduce(upgrades, ((total, n) -> total * n.benefit[1]) , 1)

  yoClick: ->
    @yos += @yoMultiplier()
    if @yos >= @profitPrice
      @showProfitButton = true

  cashClick: ->
    yosToSell = Math.min(@yos, @profitPrice * @sellMultiplier())
    @yos -= yosToSell
    @cash += (yosToSell / (@profitPrice * @sellMultiplier())) * @sellMultiplier()
    @showCash = true
    if @cash > 5
      @showUpgrades = true

  init: ->
    console.log "Game init"
    @_setupFPSMeter()
    @_startGameLoop()

  _startGameLoop: ->
    boundUpdate = (=> @_update())
    if @test
      setInterval(boundUpdate, 1000/300)
    else
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
    delta *= 100 if @test

    @_generateYos(delta)
    @_generateCash(delta)
    @_buyUpgrades() if @test

  _generateYos: (delta) ->
    for gen in @yoGen
      if gen.benefit[0] == 'yo'
        @yos += delta * gen.owned * gen.benefit[1]
      else
        gen2 = _.find(@yoGen, ((o) -> o.name == gen.benefit[0]))
        gen2.owned += delta * gen.benefit[1] * gen.owned
  _generateCash: (delta) ->
    for gen in @cashGen
      if gen.benefit[0] == 'cash'
        yosToSell = Math.min(delta * gen.owned * gen.benefit[1], @yos)
        @yos -= yosToSell
        @cash += yosToSell / @profitPrice
      else
        gen2 = _.find(@cashGen, ((o) -> o.name == gen.benefit[0]))
        gen2.owned += delta * gen.benefit[1] * gen.owned
  _buyUpgrades: ->
    @yoClick()
    @cashClick()
