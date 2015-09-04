CrystalToolsView = require './crystal-tools-view'
{CompositeDisposable} = require 'atom'
ChildProcess = require 'child_process'
ProcessView = require './process-view'
Location = require './location'
ContextResultView = require './context-result-view.coffee'
ImplementationsResultView = require './implementations-result-view.coffee'
Tmp = require 'tmp'
FS = require 'fs'

module.exports = CrystalTools =
  config:
    crystalCompiler:
      type: 'string'
      default: 'crystal'
      order: 1
    useSpecOnSrc:
      title: 'Compile ./spec/** when running tools in ./src/**'
      type: 'boolean'
      default: true
      order: 2
    mainSrc:
      title: 'Compile specified file when running tools. (blank for current file)'
      type: 'string'
      default: ''
      order: 3

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
      editor.save()
      location = Location.fromEditorCursor(editor)
      crystal = atom.config.get('crystal-tools.crystalCompiler')
      view = new ProcessView(command, location)
      main = @getMainFor(location.filename)
      @crystalToolsView.addView(view)

      usr_command = "#{crystal} #{command} --cursor #{location.cursor()} --format json --no-color #{main.name}"
      usr_command_options = {cwd: main.cwd}
      ChildProcess.exec usr_command, usr_command_options, (error, stdout, stderr) ->
        view.renderCallback(usr_command, result_view)(error, stdout, stderr)
        main.remove()

  getMainFor: (filename) ->
    components = atom.project.relativizePath(filename)
    if atom.config.get('crystal-tools.useSpecOnSrc') && components[1].startsWith("src/")
      tmpobj = Tmp.fileSync dir: components[0], prefix: 'atom-crystal-tools-', postfix: '.cr'
      FS.writeSync tmpobj.fd, """
      require "spec"
      require "./spec/**"
      """
      {
        cwd: components[0],
        name: tmpobj.name,
        remove: -> tmpobj.removeCallback()
      }
    else if atom.config.get('crystal-tools.mainSrc') != ''
      {
        cwd: components[0],
        name: atom.config.get('crystal-tools.mainSrc'),
        remove: ->
      }
    else
      {
        cwd: components[0],
        name: components[1],
        remove: ->
      }

  context: ->
    @_cursorCommand("context", new ContextResultView())

  implementations: ->
    @_cursorCommand("implementations", new ImplementationsResultView())
