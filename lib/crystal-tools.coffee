CrystalToolsView = require './crystal-tools-view'
{CompositeDisposable} = require 'atom'
ChildProcess = require 'child_process'

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
    @modalPanel = atom.workspace.addRightPanel(item: @crystalToolsView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'crystal-tools:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'crystal-tools:context': => @context()

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

  context: ->
    @ensureVisible()
    editor = atom.workspace.getActiveTextEditor()
    if editor != ''
      path = editor.getPath()
      point = editor.getCursorBufferPosition()
      line = point.row + 1
      column = point.column + 1
      crystal = atom.config.get('crystal-tools.crystalCompiler')

      ChildProcess.exec "#{crystal} context --cursor #{path}:#{line}:#{column} --format json #{path}", (error, stdout, stderr) =>
        @crystalToolsView.showContext(JSON.parse(stdout))
        @crystalToolsView.showError(stderr)
        if error != null
          @crystalToolsView.showError('exec error: ' + error)
