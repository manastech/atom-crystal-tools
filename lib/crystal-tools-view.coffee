{View} = require 'space-pen'

module.exports =
class CrystalToolsView extends View
  constructor: (serializedState) ->
    super()

  @content: ->
    @div class: "crystal-tools", =>
      @h1 "Crystal Tools"
      @div class: "help", outlet: "help", =>
        @p =>
          @text "Enables built in tools in "
          @a "crystal", href:"http://crystal-lang.org"
          @text " compiler to be used from atom."

        @p =>
          @dl =>
            @dt "Context"
            @dd "Displays available context variables at a specific location"

            @dt "Implementations"
            @dd "Over a method call, search for all possible definition of the method. Even across macro expansions."

        @p =>
          @a href: 'https://github.com/manastech/atom-crystal-tools', =>
            @span class: 'icon icon-mark-github'

      @ol class: "list-tree", outlet: "messages"

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
