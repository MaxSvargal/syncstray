'use strict'

http =  require 'http'
path = require 'path'
fs = require 'fs'
gui = global.window.nwDispatcher.requireNwGui()
siteurl = 'http://syncstray.maxsvargal.com'

module.exports = class Updater
  constructor: (@observer) ->
    @getLastVersionData => 
      @checkVersion => 
        @processUpdate()
    return

  checkVersion: (callback) ->
    currentVersion = gui.App.manifest.version
    versionRegExp = /^(\d+).(\d+).(\d+)$/
    latestVersion = @lastVersionData.version
    versionArray = latestVersion.match versionRegExp
    if versionArray
      currVersionArray = currentVersion.match versionRegExp
      for i in [1..3]
        if parseFloat(versionArray[i]) > parseFloat(currVersionArray[i])
          @showUpdateMessage currentVersion, latestVersion
          callback()

  getLastVersionData: (callback) ->
    url = siteurl + '/version.json'
    http.get(url).on 'response', (resp) =>
      data = ''
      resp.on 'data', (chunk) -> data += chunk
      resp.on 'end', =>
        @lastVersionData = JSON.parse data
        callback this

  showUpdateMessage: (curr, last) ->
    @observer.publish 'showMessage', [
      'New version available!',
      "I can download and install updates now.<br>
      Current version: #{curr}, latest: <strong>#{last}</strong>"
    ]

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
    outDir = if os is 'lin' then process.execPath else process.cwd()
    @outputFile = path.join path.dirname(outDir), 'package.nw.new'
    @dlUpdateFile @outputFile, =>
      switch os
        when 'osx' then @installMac()
        when 'lin' then @installLin()
        when 'win' then @installWin()
        else return

  installMac: =>
    window.console.log 'install for mac', @outputFile
    outDir = path.dirname @outputFile
    installDir = path.join outDir, 'app.nw'
    #fs.unlink installDir, =>
    fs.rename @outputFile, installDir
    window.console.log 'update completed'

  getPlatform: ->
    switch process.platform
      when 'win32' or 'win64' then 'win'
      when 'darwin' then 'osx'
      when 'linux' then 'lin'
      else false
