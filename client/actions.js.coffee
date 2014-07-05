Template.actions.events
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
  showUpgrades: -> Game.showUpgrades

  upgrades: ->
    _.filter Game.upgrades, (u, i) ->
      if i == 0 || Game.upgrades[i-1].active
        return true
      # u.active || (u.cost / 2 < Game.cash)
  yoGen: ->
    _.filter Game.yoGen, (u, i) ->
      if i == 0
        return true
      Game.yoGen[i-1].owned > 0
  cashGen: ->
    _.filter Game.cashGen, (u, i) ->
      if i == 0
        return true
      Game.cashGen[i-1].owned > 0
