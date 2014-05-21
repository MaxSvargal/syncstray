params =
  appID: '4138123'
  appSecret: '9c7G6T5bZkVE097J3AMI'
  dlPath: global.window.localStorage.getItem 'dlPath'
  dlThreads: global.window.localStorage.getItem 'dlThreads' or 4
  token: null
  watch: true

gui = global.window.nwDispatcher.requireNwGui()
win = gui.Window.get()
win.showDevTools()

Webi = require './syncstray/webinterface'
Auth = require './syncstray/authentication'
Collection = require './syncstray/collection'
Observer = require './syncstray/observer'
Updater = require './syncstray/updater'

observer = new Observer
updater = new Updater observer
auth = new Auth observer, params
webi = new Webi observer, params
collection = new Collection observer, params

checkDlFolder = (callback) ->
  if not params.dlPath
    observer.publish 'showMessage',
      title: 'Please, select folder'
      body: 'for download your music.'
      okBtnLabel: 'Select'
      onOkBtnClick: ->
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

win.on 'close', -> 
  observer.publish 'stopDownload'
  @hide()
  @setShowInTaskbar false

# Start app here
checkDlFolder -> 
  updater.check()
  initialize()