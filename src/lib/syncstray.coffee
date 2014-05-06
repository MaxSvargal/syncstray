params =
  appID: '4138123'
  appSecret: '9c7G6T5bZkVE097J3AMI'
  dlPath: global.window.localStorage.getItem 'dlPath'
  dlThreads: global.window.localStorage.getItem 'dlThreads'
  token: null
  watch: true

if params.dlThreads is null then params.dlThreads = 4

gui = global.window.nwDispatcher.requireNwGui()
win = gui.Window.get()
win.showDevTools()
Webi = require './syncstray/webinterface'
Auth = require './syncstray/authentication'
Collection = require './syncstray/collection'
Observer = require './syncstray/observer'
Updater = require './syncstray/updater'

updater = new Updater
observer = new Observer
auth = new Auth observer, params
webi = new Webi observer, params
collection = new Collection observer, params

checkDlFolder = (callback) ->
  if not params.dlPath
    global.window.alert 'Please, select folder for download.'
    webi.chooseFolderDialog (folder) ->
      params.dlPath = folder
      global.window.localStorage.setItem 'dlPath', folder
      callback()
  else
    callback()

initTray = ->
  tray = new gui.Tray
    icon: 'assets/favicon.png'
  menu = new gui.Menu

  item_show = new gui.MenuItem
    label: 'Show Program'

  item_dl = new gui.MenuItem
    type: 'checkbox'
    checked: false
    label: 'Disable download'

  item_exit = new gui.MenuItem
    label: 'Exit'

  menu.append item_show
  menu.append item_dl
  menu.append item_exit
  tray.menu = menu

  item_exit.on 'click', -> gui.App.quit()
  item_show.on 'click', -> win.show()
  item_dl.on 'click', -> observer.publish 'toggleDownload'

  observer.subscribe 'toggleDownload', ->
    item_dl.label = if item_dl.checked then 'Disable download' else 'Enable download'
    item_dl.checked = if item_dl.checked then false else true


initialize = ->
  auth.login (token) ->
    collection.params.token = token
    collection.get (data) ->
      webi.showMusicList data
      collection.download()
      return

win.on 'close', -> 
  @hide()
  @setShowInTaskbar false


# Start app here
initTray()
checkDlFolder ->
  initialize()
  updater.checkVersion()
