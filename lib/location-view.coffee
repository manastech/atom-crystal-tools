{View} = require 'space-pen'

module.exports =
  class LocationView extends View
    constructor: (@location) ->
      super()
      @filename.text(atom.project.relativizePath(@location.filename)[1])
      @line.text(@location.line)
      @column.text(@location.column)

    @content: ->
      @a click: "open", =>
        @span outlet: "filename", "<filename>"
        @text ":"
        @span outlet: "line", "<line>"
        @text ":"
        @span outlet: "column", "<column>"

    open: ->
      console.log("opening")
      atom.workspace.open @location.filename,
        initialLine: @location.line - 1
        initialColumn: @location.column - 1
