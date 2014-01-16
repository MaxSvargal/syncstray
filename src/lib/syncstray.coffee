params =
  appID: '4027411'
  appSecret: 'MDn6yOgRLmkWBbm1PTFL'
  dlPath: "#{__dirname}/../cache"
  dlThreads: 2
  token: null

webI = require './webInterface'
auth = require('./authentication')(params)
collection = require('./collection')(params, webI)

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