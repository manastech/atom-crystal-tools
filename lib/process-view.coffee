{View} = require 'space-pen'
LocationView = require './location-view'

module.exports =
  class ProcessView extends View
    constructor: (command, location) ->
      super()
      @command.text(command)
      @location.append(new LocationView(location))

    @content: ->
      @div =>
        @h2 =>
          @span outlet: "command", "<command>"
          @text " "
          @span outlet: "location"
        @button click: 'removeFromParent', "remove"
        @div outlet: "output", "loading..."

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
