params =
  appID: '4027411'
  appSecret: 'MDn6yOgRLmkWBbm1PTFL'
  dlPath: "#{__dirname}/cache"
  token: null

webI = require './webInterface'
vkAuth = require('./vkAuth')(params)
musicParser = require('./musicParser')(params)

musicParser.getCachedCollection (data) ->
  if data.code
    vkAuth.initialize (token) ->
      params.token = token
      musicParser.getCollectionFromServer (music) ->
        webI.showMusicList music
        return
  webI.showMusicList data

