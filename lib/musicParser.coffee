http = require 'http'
https = require 'https'
fs = require 'fs'
colors = require 'colors'

module.exports = (params) ->

  musicJson = null
  cacheJsonPath = "#{__dirname}/../cache.json"

  writeJsonToFile = (data, callback) ->
    fs.writeFile cacheJsonPath, data, (err) ->
      if err then throw err
      console.log "Music list cached.".cyan
      callback()

  getCachedCollection = (callback) ->
    fs.readFile cacheJsonPath, 'utf8', (err, data) ->
      musicJson = (JSON.parse data).response
      callback musicJson

  downloadTrack = (data, callback) ->
    filename = "#{data.artist} - #{data.title}.mp3"
    console.log "Start download track".grey, filename.magenta
    
    file = fs.createWriteStream "#{params.dlPath}/#{filename}"
    file.on 'error', (e) ->
      console.log "Error write file '#{filename}'. Aborted.".red.bold

    http.get data.url, (response) ->
      response.pipe file

      response.on 'error', ->
        console.log "Error with file '#{filename}'. Aborted.".red.bold

      response.on 'end', ->
        console.log filename.bold, " downloaded.".green
        callback()

  checkOnExists = (data, callback) ->
    filename = "#{data.artist} - #{data.title}.mp3"
    fs.exists "#{params.dlPath}/#{filename}", (exists) ->
      callback exists

  return {
    downloadCollection: ->
      getCachedCollection ->
        if musicJson.length isnt 0
          collectionPosition = 0
          loopFn = ->
            track = musicJson[collectionPosition++]
            return if not track
            # Trim strings for corrective filename
            try
              filteredSymbols = [
                ['/', '']
                ['[', '']
                [']', '']
                [/\s{2,}/g, ' ']
              ]
              for symbol in filteredSymbols
                track.artist = track.artist.replace symbol[0], symbol[1]
                track.title = track.title.replace symbol[0], symbol[1]

            catch error
              console.log error.toString().red.bold
              return

            checkOnExists track, (exists) ->
              if exists
                console.log "#{track.artist} - #{track.title}.mp3" + ' already exists.'.yellow
                loopFn()
              else
                downloadTrack track, -> loopFn()

          for [0..params.dlThreads-1]
            loopFn()
        else
          console.log "No tracks in your collection.".red

    getCollectionFromServer: (token, callback) ->
      options = 
        host: 'api.vk.com'
        port: 443
        path: "/method/audio.get?access_token=#{token}"

      https.get options, (res) ->
        response = new String
        res.setEncoding 'utf8'
        res.on 'data', (chunk) -> response += chunk
        res.on 'end', ->
          musicJson = (JSON.parse response).response
          writeJsonToFile response, ->
            callback response
  }
