{View} = require 'space-pen'

module.exports =
  class LocationView extends View
    constructor: (@location) ->
      super()
      components = atom.project.relativizePath(@location.filename)

      # strip path if and show icon if applicable
      if components[0] == null
        paths = atom.config.get('crystal-tools.stripPath').split(':')
        for path in paths
          if components[1].startsWith(path)
            @crystal.removeClass("hidden")
            components[1] = components[1].substr(path.length + 1)
            break

      @filename.text(components[1])
      @line.text(@location.line)
      @column.text(@location.column)

    @content: ->
      @a click: "open", =>
        @span outlet: "crystal", class: "icon icon-ruby hidden"
        @span outlet: "filename", "<filename>"
        @text ":"
        @span outlet: "line", "<line>"
        @text ":"
        @span outlet: "column", "<column>"

    open: ->
      atom.workspace.open @location.filename,
        initialLine: @location.line - 1
        initialColumn: @location.column - 1
