'use strict'

http =  require 'http'
gui = global.window.nwDispatcher.requireNwGui()

module.exports = class Updater
  constructor: (@observer) ->
    @newVersionHandle([0,2,2], [0,3,0])
    return

  checkVersion: ->
    siteurl = 'http://syncstray.maxsvargal.com/'
    url = siteurl + 'lastversion.dat'
    currentVersion = gui.App.manifest.version
    versionRegExp = /^(\d+).(\d+).(\d+)$/
    http.get(url).on 'response', (resp) =>
      version = ''
      resp.on 'data', (chunk) -> version += chunk
      resp.on 'end', =>
        versionArray = version.match versionRegExp
        if versionArray
          currVersionArray = currentVersion.match versionRegExp
          i = 1
          for [1..3]
            if parseFloat(versionArray[i]) > parseFloat(currVersionArray[i])
              @newVersionHandle(currVersionArray, versionArray)
              return
            i++

  newVersionHandle: (curr, last) ->
    window.console.log 'WAT?'
    @observer.publish 'showMessage', [
      'New version available!',
      "We can download and install updates now.<br>
      Latest version: #{last}, current: #{curr}"
    ]