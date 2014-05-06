'use strict'

http =  require 'http'
gui = global.window.nwDispatcher.requireNwGui()

module.exports = class Updater
  checkVersion: ->
    siteurl = 'http://syncstray.maxsvargal.com/'
    url = siteurl + 'lastversion.dat'
    currentVersion = gui.App.manifest.version
    versionRegExp = /^(\d+).(\d+).(\d+)$/
    http.get(url).on 'response', (resp) ->
      version = ''
      resp.on 'data', (chunk) -> version += chunk
      resp.on 'end', ->
        versionArray = version.match versionRegExp
        if versionArray
          currVersionArray = currentVersion.match versionRegExp
          i = 1
          for [1..3]
            if parseFloat(versionArray[i]) > parseFloat(currVersionArray[i])
              global.window.alert 'I have new version! Please, update me!'
              gui.Shell.openExternal siteurl
              return
            i++