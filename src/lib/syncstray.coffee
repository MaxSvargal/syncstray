params =
  appID: '4027411'
  appSecret: 'MDn6yOgRLmkWBbm1PTFL'
  dlPath: global.window.localStorage.getItem 'dlPath'
  dlThreads: 4
  token: null

gui = global.window.nwDispatcher.requireNwGui()
http =  require 'http'
#gui.Window.get().showDevTools()
webI = require './webInterface'
auth = require('./authentication')(params)
collection = require('./collection')(params, webI)

checkVersion = ->
  siteurl = 'http://syncstray.maxsvargal.com/'
  url = siteurl + 'lastversion.dat'
  currentVersion = gui.App.manifest.version
  versionRegExp = /^(\d+).(\d+).(\d+)$/
  http.get(url).on 'response', (resp) ->
    version = ''
    resp.on 'data', (chunk) ->
      version += chunk
    resp.on 'end', ->
      versionArray = version.match versionRegExp
      if versionArray
        currVersionArray = currentVersion.match versionRegExp
        i = 1
        for [1..3]
          if parseFloat(versionArray[i]) > parseFloat(currVersionArray[i])
            console.log "On server new version!"
            global.window.alert 'I have new version! Please, update me!'
            gui.Shell.openExternal siteurl
          i++
      
initialize = ->
  webI.registerDomEvents collection
  collection.getCachedCollection (data) ->
    if data.length is 0
      auth.initialize (token) ->
        params.token = token
        collection.getCollectionFromServer (music) ->
          webI.showMusicList music
          collection.downloadCollection music
          return
    else
      webI.showMusicList data
      collection.downloadCollection data
      return

if not params.dlPath
  checkVersion()
  webI.chooseFolderDialog (folder) ->
    params.dlPath = folder
    global.window.localStorage.setItem 'dlPath', folder
    initialize()
else
  initialize()
  checkVersion()

win = gui.Window.get()
win.on 'close', ->
  @hide()
  collection.stopCurrDownloads ->
    win.close true
    gui.App.quit()