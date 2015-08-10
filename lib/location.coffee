module.exports =
  class Location
    constructor: (@filename, @line, @column) ->

    filename: ->
      @filename

    @fromEditorCursor: (editor) ->
      path = editor.getPath()
      point = editor.getCursorBufferPosition()
      line = point.row + 1
      column = point.column + 1

      new Location(path, line, column)

    cursor: ->
      "#{@filename}:#{@line}:#{@column}"
