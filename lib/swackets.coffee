{CompositeDisposable} = require "atom"
SwacketsView = require './swackets-view'

module.exports =

  config:
    colors:
      default: ['#ba8cb8', '#8ab7d8', '#60dd60', '#ffff70', '#ea9d70', '#e76464']
      type: 'array'
      items:
        type: 'string'

    parenthesis:
      title: '(parenthesis)'
      type : 'boolean'
      default : true

    curlies:
      title: '{curlies}'
      type : 'boolean'
      default : true


  areaView: null

  activate: (state) ->
    @areaView = new SwacketsView()

  deactivate: ->
    @areaView.destroy()
    @areaView = null
