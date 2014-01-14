exports.initialize = (args, gui) ->
  params =
    appID: '4027411'
    appSecret: 'MDn6yOgRLmkWBbm1PTFL'
    dlPath: "#{__dirname}/cache"

  vkAuth = require('./vkAuth')(params, gui)
  musicParser = require('./musicParser')(params)

  vkAuth.initialize (token) ->
    console.log "TOKEN: ", token
    musicParser.getCollectionFromServer token, (music) ->
      musicParser.downloadCollection()