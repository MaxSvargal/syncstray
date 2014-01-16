http = require 'http'
https = require 'https'
fs = require 'fs'
gui = global.window.nwDispatcher.requireNwGui()
path = require 'path'
Datastore = require 'nedb'
db = new Datastore { filename: path.join(gui.App.dataPath, 'collection.db'), autoload: true }

module.exports = (params, webI) ->

  musicJson = null
  cacheJsonPath = "#{__dirname}/../cache.json"

  saveCollection = (data, callback) ->
    db.insert data, (err, collection) ->
      if err then throw err
      console.log "Music list cached."
      callback collection

  downloadTrack = (data, callback) ->
    filename = "#{data.artist} - #{data.title}.mp3"
    console.log "Start download track", filename

    file = fs.createWriteStream "#{params.dlPath}/#{filename}", { flags: 'a' }

    file.on 'error', (e) ->
      console.log "Error write file '#{filename}'. Aborted."

    http.get data.url, (res) ->
      fsize = res.headers['content-length']
      len = 0
      res.on 'data', (chunk) ->
        file.write chunk, encoding='binary'
        len += chunk.length
        percent = Math.round len / fsize * 100
        webI.setProgressBar data.aid, percent

      res.on 'error', ->
        console.log "Error with file '#{filename}'. Aborted."

      res.on 'end', ->
        file.end()
        console.log filename, " downloaded."
        callback()

  checkOnExists = (data, callback) ->
    filename = "#{data.artist} - #{data.title}.mp3"
    fs.exists "#{params.dlPath}/#{filename}", (exists) ->
      callback exists

  return {
    getCachedCollection: (callback) ->
      db.find {}, (err, collection) ->
        callback collection

    downloadCollection: ->
      @getCachedCollection (collection) ->
        if collection.length isnt 0
          pos = 0
          loopFn = ->
            track = collection[pos++]
            #return if not track
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
              console.log error.toString()
              return
            checkOnExists track, (exists) ->
              if exists
                console.log "#{track.artist} - #{track.title}.mp3" + ' already exists.'
                webI.setStatus 'downloaded', track.aid
                loopFn()
              else
                webI.setStatus 'onprogress', track.aid
                downloadTrack track, -> loopFn()

          for [0..params.dlThreads-1]
            loopFn()
        else
          console.log "No tracks in your collection."

    getCollectionFromServer: (callback) ->
      options = 
        host: 'api.vk.com'
        port: 443
        path: "/method/audio.get?access_token=#{params.token}"

      https.get options, (res) ->
        response = new String
        res.setEncoding 'utf8'
        res.on 'data', (chunk) -> response += chunk
        res.on 'end', ->
          musicJson = (JSON.parse response).response
          saveCollection musicJson, (collection) ->
            callback collection
  }
