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
    Game.yoClick()

  'click #profitButton': (e) ->
    Game.cashClick()
