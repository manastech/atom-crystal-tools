{View} = require 'space-pen'
LocationView = require './location-view'
Location = require './location'

module.exports =
  class ImplementationsResultView extends View

    load: (response) ->
      @message.text(response.message)
      if response.status != "ok"
        return
      for impl in response.implementations
        @implementations.append(new ImplementationItemView(impl))

    @content: ->
      @div class: "implementations-result-view", =>
        @span outlet: "message"
        @ol outlet: "implementations"
        @div outlet: "jsonres"

class ImplementationItemView extends View
  constructor: (item) ->
    super()
    @prefix.text(item.macro) if item.macro
    @location.append(new LocationView(new Location(item.filename, item.line, item.column)))
    @inner.append(new ImplementationItemView(item.expands)) if item.expands

  @content: ->
    @li =>
      @span outlet: "prefix"
      @text " "
      @span outlet: "location"
      @ul outlet: "inner"
