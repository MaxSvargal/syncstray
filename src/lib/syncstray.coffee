params =
  appID: '4027411'
  appSecret: 'MDn6yOgRLmkWBbm1PTFL'
  dlPath: global.window.localStorage.getItem 'dlPath'
  dlThreads: 2
  token: null

gui = global.window.nwDispatcher.requireNwGui()
#gui.Window.get().showDevTools()
http =  require 'http'
webi = require './webinterface'
Auth = require './authentication'
Collection = require './collection'

auth = new Auth params
collection = new Collection params
webi = new webi


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

checkDlFolder = (callback) ->
  if not params.dlPath
    global.window.alert 'Please, select folder for download.'
    webi.chooseFolderDialog (folder) ->
      params.dlPath = folder
      global.window.localStorage.setItem 'dlPath', folder
      callback()
  else
    callback()

initialize = ->
  collection.subscribe 'setProgressBar', webi.setProgressBar
  collection.subscribe 'circleCounter', webi.circleCounter
  collection.subscribe 'setItemStatus', webi.setItemStatus
  webi.subscribe 'toggleDownload', collection.toggleDownload
  webi.subscribe 'reloadCollectionDl', collection.reloadCollectionDl
  webi.subscribe 'logout', auth.logout

  auth.login (token) ->
    collection.params.token = token
    collection.get (data) ->
      webi.showMusicList data
      collection.download()
      return


win = gui.Window.get()
win.on 'close', ->
  @hide()
  collection.stopCurrDownloads ->
    win.close true
    gui.App.quit()


checkDlFolder ->
  initialize()
  checkVersion()
