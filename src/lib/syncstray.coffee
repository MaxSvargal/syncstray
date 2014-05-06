params =
  appID: '4138123'
  appSecret: '9c7G6T5bZkVE097J3AMI'
  dlPath: global.window.localStorage.getItem 'dlPath'
  dlThreads: global.window.localStorage.getItem 'dlThreads'
  token: null
  watch: true

if params.dlThreads is null then params.dlThreads = 4

gui = global.window.nwDispatcher.requireNwGui()
gui.Window.get().showDevTools()
http =  require 'http'
Webi = require './syncstray/webinterface'
Auth = require './syncstray/authentication'
Collection = require './syncstray/collection'
Observer = require './syncstray/observer'

observer = new Observer
auth = new Auth observer, params
webi = new Webi observer, params
collection = new Collection observer, params

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
  auth.login (token) ->
    collection.params.token = token
    collection.get (data) ->
      webi.showMusicList data
      collection.download()
      return

win = gui.Window.get()
win.on 'close', ->
  @hide()
  collection.stopCurrDownloads
  gui.App.quit()

checkDlFolder ->
  initialize()
  checkVersion()
