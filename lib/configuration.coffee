fs = require('fs')
Backbone = require ('backbone')

class ConfigurationManager extends Backbone.Model
  rootConfigDir: -> 
    "#{process.env.HOME}/.mredcontext"
  configDir: -> 
    path = @get('rootPath').replace(/\//g, '_')
    "#{@rootConfigDir()}/#{path}"
  configPath: ->
    "#{@configDir()}/settings.json"

  initialize: ->
    @on('change', => @_writeConfig())

  loadConfigFor: (path) ->
    promise = new $.Deferred()
    @set(rootPath: path, {silent: true})
    @_createConfigDir().done(=>
      fs.exists(@configPath(), (exists) =>
        if exists
          fs.readFile(@configPath(), 'utf8', (err, data) => 
            if err
              promise.reject(err)
              throw err
            try
              result = JSON.parse(data)
            catch e
              console.error("failed parsing stored configuration from disk '#{@configPath()}'")
              promise.reject(e)
              throw e
            @set(result, {silent: true})
            promise.resolve()
          )
        else
          #config file does not exist
          promise.resolve()
      )
    )
    promise

  _writeConfig: _.throttle((->
    fs.writeFile(@configPath(), JSON.stringify(@toJSON()), 'utf8', (err) ->
      if err
        throw err
    )
  ), 500)

  _createDirUnlessItExists: (path) ->
    promise = new $.Deferred()
    fs.exists(path, (exists) ->
      if exists
        promise.resolve()
      else
        fs.mkdir(path, (err) -> 
          if err
            promise.reject(err)
            throw err
          promise.resolve()
        )
    )
    promise

  _createConfigDir: ->
    promise = new $.Deferred()
    @_createDirUnlessItExists(@rootConfigDir()).done(@_createDirUnlessItExists(@configDir()).done(promise.resolve))
    promise

exports.configuration = new ConfigurationManager()
