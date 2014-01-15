params =
  appID: '4027411'
  appSecret: 'MDn6yOgRLmkWBbm1PTFL'
  dlPath: "#{__dirname}/cache"
  token: null

vkAuth = require('./vkAuth')(params)
vkAuth.initialize (token) ->
  params.token = token
  musicParser = require('./musicParser')(params)

  musicParser.getCollectionFromServer (music) ->
    #musicParser.downloadCollection()
    return