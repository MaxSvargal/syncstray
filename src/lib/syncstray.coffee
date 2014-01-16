params =
  appID: '4027411'
  appSecret: 'MDn6yOgRLmkWBbm1PTFL'
  dlPath: global.window.localStorage.getItem 'dlPath'
  dlThreads: 4
  token: null

webI = require './webInterface'
auth = require('./authentication')(params)
collection = require('./collection')(params, webI)

initialize = ->
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
  webI.chooseFolderDialog (folder) ->
    params.dlPath = folder
    global.window.localStorage.setItem 'dlPath', folder
    initialize()
else
  initialize()