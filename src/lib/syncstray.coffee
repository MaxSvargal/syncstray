params =
  appID: '4027411'
  appSecret: 'MDn6yOgRLmkWBbm1PTFL'
  dlPath: global.window.localStorage.getItem 'dlPath'
  dlThreads: 4
  token: null

gui = global.window.nwDispatcher.requireNwGui()
gui.Window.get().showDevTools()
http =  require 'http'
webI = require './webInterface'
Auth = require './authentication'
Collection = require './collection'
#options = require './options'

checkVersion = ->
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
      
initialize = ->
  auth = new Auth params
  collection = new Collection params

  collection.subscribe 'setProgressBar', webI.setProgressBar

  auth.login (token) ->
    collection.params.token = token
    collection.get (data) ->
      webI.showMusicList data
      collection.download()
      return
###
  collection.getCachedCollection (data) ->
    if data.length is 0
      auth.login (token) ->
        params.token = token
        collection.getCollectionFromServer (music) ->
          webI.showMusicList music
          collection.downloadCollection()
          return
    else
      webI.showMusicList data
      collection.downloadCollection()
      return
###

if not params.dlPath
  checkVersion()
  global.window.alert 'Please, select folder for download.'
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