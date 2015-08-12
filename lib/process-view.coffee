{View} = require 'space-pen'
LocationView = require './location-view'

module.exports =
  class ProcessView extends View
    constructor: (command, location) ->
      super()
      @command.text(command)
      @location.append(new LocationView(location))

    @content: ->
      @li class: "list-nested-item", =>
        @div class: "header list-item", =>
          @span class: "icon icon-circuit-board", outlet: "command", "<command>"
          @text " "
          @span class: "process-view-location", outlet: "location"
          @a class:'close-icon icon icon-x', click: 'removeFromParent'
        @p class: "entries", outlet: "output", "loading..."

    removeFromParent: (event, element) ->
      @container.removeView(@element)

    setContainerView: (@container) ->

    renderCallback: (result_view) ->
      (error, stdout, stderr) =>
        if stderr != ""
          @output.text(stderr)
          return
        if error != null
          @output.text('exec error: ' + error)
          return

        try
          json_result = JSON.parse(stdout)
        catch
          @output.text("ERROR #{stdout}")
          return

        result_view.load(json_result)
        @output.html("")
        @output.append(result_view)
