Handlebars.registerHelper 'decimal', (number) ->
  Math.floor(number)

Handlebars.registerHelper 'humanize', (number) ->
  if number < 1
    return 0

  integer = Math.floor(number)
  scale = Math.floor(Math.log(integer) / Math.LN10)
  units = ["", "K", "M", "B", "T", "Q", "Qi", "Se", "Si", "Oc", "No"]
  base = (integer / Math.pow(10, scale - (scale%3)))
  roundedBase = Math.round(base*100)/100
  roundedBase + units[(scale-scale%3)/3]

Handlebars.registerHelper 'decimal', (number) ->
  Math.floor(number)

Handlebars.registerHelper 'afford', (money) ->
  money/2 < Game.cash
