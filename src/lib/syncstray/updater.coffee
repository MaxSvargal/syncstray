'use strict'

http =  require 'http'
path = require 'path'
fs = require 'fs'
zip = require 'adm-zip'
gui = global.window.nwDispatcher.requireNwGui()
siteurl = 'http://syncstray.maxsvargal.com'

module.exports = class Updater
  constructor: (@observer) ->
    return

  check: ->
    @getLastVersionData => @checkVersion()

  checkVersion: ->
    currentVersion = gui.App.manifest.version
    versionRegExp = /^(\d+).(\d+).(\d+)$/
    latestVersion = @lastVersionData.version
    versionArray = latestVersion.match versionRegExp
    if versionArray
      currVersionArray = currentVersion.match versionRegExp
      for i in [1..3]
        if parseFloat(versionArray[i]) > parseFloat(currVersionArray[i])
          @showUpdateMessage currentVersion, latestVersion

  getLastVersionData: (callback) ->
    url = siteurl + '/version.json'
    http.get(url).on 'response', (resp) =>
      data = ''
      resp.on 'data', (chunk) -> data += chunk
      resp.on 'end', =>
        @lastVersionData = JSON.parse data
        callback this

  showUpdateMessage: (curr, last) ->
    @observer.publish 'showMessage',
      title: 'New version available!'
      body: "We can download and install updates now.<br>
      Current version: #{curr}, latest: <strong>#{last}</strong>",
      okBtnLabel: 'Update'
      onOkBtnClick: => @processUpdate()

  dlUpdateFile: (outputFile, callback) ->
    url = @lastVersionData.update_url[@getPlatform()]
    http.get(url).on 'response', (resp) ->
      file = fs.createWriteStream outputFile, {flags: 'a'}
      resp.on 'data', (chunk) -> file.write chunk
      resp.on 'end', ->
        file.end()
        callback()

  processUpdate: =>
    os = @getPlatform()
    @binDir = if os is 'lin' then process.execPath else process.cwd()
    @dlPath = path.join path.dirname(@binDir), 'update.zip'
    @dlUpdateFile @dlPath, =>
      switch os
        when 'osx' then @installMac()
        when 'lin' then @installLin()
        when 'win' then @installWin()
        else return

  installMac: =>
    window.console.log 'extract', @dlPath, 'to', @binDir
    pack = new zip @dlPath
    try
      pack.extractAllTo @binDir, true
      fs.unlink @dlPath, (err) ->
        throw err if err
        window.console.log 'Update complete'
    catch err
      throw 'Cant extract archive'

  installWin: =>
    return

  getPlatform: ->
    switch process.platform
      when 'win32' or 'win64' then 'win'
      when 'darwin' then 'osx'
      when 'linux' then 'lin'
      else false
