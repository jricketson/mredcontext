fs = require ('fs')
FileModel = require('./models/file')

class Application

  CODEMIRROR_LOCATION: "vendor/codemirror-3.0rc1" 

  setupShortcuts: ->
    $(document).bind('keydown', 'ctrl+s', -> editorPane().saveActive())

  reloadLayout: ->
    #To reload the layout before the filelist has finished loading, 
    #the filelist needs some smarts about finding files on disk vs ones that have already been found from reloading the layout
    console.log('reloading layout')
    layout = @configuration.get('layout')
    for conf in layout || []
      file = @fileList().getByPath(conf.path)
      unless file?
        file = new FileModel.File(path:conf.path)
        @fileList().add(file)
      @editorPane().showEditorForFile(file, position:conf.position, line:conf.line)
    console.log('layout reloaded')

  loadPlugins: ->
    promise = new $.Deferred()
    fs.readdir("#{process.cwd()}/plugins", (error, files) =>
      for f in files
        if f[0] != '.'
          console.log("loading plugin #{f}")
          module = require("#{process.cwd()}/plugins/#{f}")
          module.register()
      promise.resolve()
    )
    promise

  loadCssResource: (url) ->
    $('head').append("<link rel='stylesheet' type='text/css' href='#{url}' />")

  bootstrap: ->
    @fileList = require('./models/file_list').fileList
    @editorPane = require('./views/editor_pane_view').editorPane
    @configuration = require('./configuration').configuration

    root_path = GUI.App.argv[0]
    console.log("Starting in '#{root_path}'")
    @configuration.loadConfigFor(root_path).done => 
      console.log('config loaded')
      @loadPlugins().done =>
        console.log('plugins loaded')
        @fileList().startRead().done (elapsedMilliSeconds) =>
          console.log("finished reading #{@fileList().length} files in #{elapsedMilliSeconds}ms")
        @reloadLayout()
        @editorPane().on('layoutUpdated', (layout) => @configuration.set(layout:layout))  

        @setupShortcuts()

exports.application = -> @_application ||= new Application()
