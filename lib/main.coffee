fs = require 'fs'

exports.initialize = (args, gui) ->
  configName = if args.length isnt 0 then args[0] else 'main'
  configPath = "#{__dirname}/../users/#{configName}.json"
  fs.exists configPath, (exists) ->
    if not exists 
      throw new Error "Config #{configName} doesn't exists."
      return

    params = require configPath
    params.appID = '4027411'
    params.appSecret = 'MDn6yOgRLmkWBbm1PTFL'
    params.dlPath = if params.dlPath is null then "#{__dirname}/cache" else params.dlPath

    vkAuth = require('./vkAuth')(params, gui)
    musicParser = require('./musicParser')(params)

    vkAuth.initialize (token) ->
      console.log "TOKEN: ", token
      musicParser.getCollectionFromServer token, (music) ->
        musicParser.downloadCollection()