{View} = require 'space-pen'

module.exports =
class CrystalToolsView extends View
  constructor: (serializedState) ->
    super()

  @content: ->
    @div class: "crystal-tools", =>
      @h1 "Crystal Tools"
      @button click: "clearMessages", "clear all"
      @div outlet: "help", =>
        @p "TBD: Intro to crystal tools"
      @div outlet: "messages"

  clearMessages: (event, element) ->
    @messages.html("")
    @help.show()

  addView: (view) ->
    @help.hide()
    view.setContainerView(@)
    @messages.prepend(view.element)

  removeView: (view) ->
    view.remove()
    @help.show() if @messages.children().length == 0

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()
