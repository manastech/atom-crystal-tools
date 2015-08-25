CrystalToolsView = require './crystal-tools-view'
{CompositeDisposable} = require 'atom'
ChildProcess = require 'child_process'
ProcessView = require './process-view'
Location = require './location'
ContextResultView = require './context-result-view.coffee'
ImplementationsResultView = require './implementations-result-view.coffee'

module.exports = CrystalTools =
  config:
    crystalCompiler:
      type: 'string'
      default: 'crystal'

  crystalToolsView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @crystalToolsView = new CrystalToolsView(state.crystalToolsViewState)
    @modalPanel = atom.workspace.addRightPanel(item: @crystalToolsView.element, visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'crystal-tools:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'crystal-tools:context': => @context()
    @subscriptions.add atom.commands.add 'atom-workspace', 'crystal-tools:implementations': => @implementations()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @crystalToolsView.destroy()

  serialize: ->
    crystalToolsViewState: @crystalToolsView.serialize()

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

  ensureVisible: ->
    @toggle() unless @modalPanel.isVisible()

  _cursorCommand: (command, result_view) ->
    @ensureVisible()
    editor = atom.workspace.getActiveTextEditor()
    if editor != ''
      location = Location.fromEditorCursor(editor)
      crystal = atom.config.get('crystal-tools.crystalCompiler')
      view = new ProcessView(command, location)
      main = location.filename
      @crystalToolsView.addView(view)

      ChildProcess.exec "#{crystal} #{command} --cursor #{location.cursor()} --format json --no-color #{main}", view.renderCallback(result_view)

  context: ->
    @_cursorCommand("context", new ContextResultView())

  implementations: ->
    @_cursorCommand("implementations", new ImplementationsResultView())
