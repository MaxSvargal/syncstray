http = require 'http'
https = require 'https'
fs = require 'fs'
gui = global.window.nwDispatcher.requireNwGui()
path = require 'path'
Datastore = require 'nedb'
db = new Datastore { filename: path.join(gui.App.dataPath, 'collection.db'), autoload: true }
#/Users/user/Library/Application Support/syncstray/collection.db
stopFlag = false
onProcess = 0
collCurrPos = 0
collectionBase = []

module.exports = (params, webI) ->

  counter = webI.circleCounter()

  saveCollection = (data, callback) ->
    db.insert data, (err) ->
      if err then throw err
      console.log "Music list cached."
      callback()

  downloadTrack = (data, callback) ->
    filename = "#{data.artist} - #{data.title}.mp3"
    #console.log "Start download track", filename
    file = fs.createWriteStream "#{params.dlPath}/#{filename}", { flags: 'a' }

    file.on 'error', (e) ->
      console.log "Error write file '#{filename}'. Aborted."

    http.get data.url, (res) ->
      fsize = res.headers['content-length']
      len = 0
      onProcess++
      res.on 'data', (chunk) ->
        file.write chunk
        len += chunk.length
        percent = Math.round len / fsize * 100
        webI.setProgressBar data.aid, percent

      res.on 'error', ->
        onProcess--
        console.log "Error with file '#{filename}'. Aborted."

      res.on 'end', ->
        file.end()
        onProcess--
        #console.log filename, " downloaded."
        callback() if stopFlag is false

  checkOnExists = (data, callback) ->
    filename = "#{data.artist} - #{data.title}.mp3"
    fs.exists "#{params.dlPath}/#{filename}", (exists) ->
      callback exists

  loopDlFn = ->
    track = collectionBase[collCurrPos++]
    currPerc = collCurrPos * 100 / collectionBase.length
    counter.draw (currPerc).toFixed(1)
    return if not track
    # Trim strings for corrective filename
    try
      filteredSymbols = [
        [/\//g, '']
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
        #console.log "#{track.artist} - #{track.title}.mp3" + ' already exists.'
        webI.setStatus 'downloaded', track.aid
        loopDlFn()
      else
        webI.setStatus 'onprogress', track.aid
        downloadTrack track, -> loopDlFn()

  return {
    getCachedCollection: (callback) ->
      db.find {}, (err, collection) ->
        callback collection

    downloadCollection: ->
      @getCachedCollection (collection) ->
        if collection.length isnt 0
          collectionBase = collection
          numForLoop = params.dlThreads - onProcess - 1
          for [0..numForLoop]
            loopDlFn()
        else
          webI.showNoTracks()

    getCollectionFromServer: (callback) ->
      getCachedCollection = @getCachedCollection
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
          saveCollection musicJson, ->
            getCachedCollection (collection) ->
              callback collection

    toggleDownload: ->
      if stopFlag is false
        stopFlag = true
      else
        stopFlag = false
        numForLoop = params.dlThreads - onProcess - 1
        for [0..numForLoop]
          loopDlFn()
  }
