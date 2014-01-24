'use strict'

http = require 'http'
https = require 'https'
fs = require 'fs'
gui = global.window.nwDispatcher.requireNwGui()
path = require 'path'
Datastore = require 'nedb'

module.exports = class Collection
  constructor: (@params) ->
    @db = new Datastore { filename: path.join(gui.App.dataPath, 'collection.db'), autoload: true }
    @db.ensureIndex { fieldName: 'aid', unique: true }
    #/Users/user/Library/Application Support/syncstray/collection.db
    @stopFlag = false
    @onProcess = 0
    @collCurrPos = 0
    @collectionDB = []
    @subscribers = []

  subscribe: (method, callback) ->
    @subscribers.push {'method': method, 'callback': callback}

  get: (callback) ->
    @getCollectionFromServer (dl_collection) =>
      @saveCollection dl_collection, =>
        @getCachedCollection (cached_collection) ->
          callback cached_collection

  download: (path) ->
    if path then @params.dlPath = path
    @getCachedCollection (collection) =>
      if collection.length isnt 0
        @collectionDB = collection
        numForLoop = @params.dlThreads - @onProcess - 1
        for [0..numForLoop]
          @loopDlFn()
      else
        @showNoTracks()

  setItemStatus: (status, id) =>
    subscriber.callback(status, id) for subscriber in @subscribers when subscriber.method is 'setItemStatus'

  setProgressBar: (aid, percent) =>
    subscriber.callback(aid, percent) for subscriber in @subscribers when subscriber.method is 'setProgressBar'

  circleCounter: (percent) =>
    subscriber.callback(percent) for subscriber in @subscribers when subscriber.method is 'circleCounter'

  saveCollection: (data, callback) ->
    @db.insert data, (err) ->
      if err then console.log err.message
      console.log "Music list cached."
      callback()

  changeDlThreads: (threads) =>
    @params.dlThreads = threads
    numForLoop = @params.dlThreads - @onProcess - 1
    if numForLoop >= 0
      for [0..numForLoop]
        @loopDlFn()

  getCachedCollection: (callback) ->
    @db.find {}, (err, collection) ->
      callback collection

  _getFileName: (data) ->
    "#{data.artist} - #{data.title}.mp3"

  downloadTrack: (data, callback) =>
    filename = @_getFileName data
    file = fs.createWriteStream "#{@params.dlPath}/#{filename}", { flags: 'a' }

    req = http.get data.url, (res) =>
      fsize = res.headers['content-length']
      len = 0
      @onProcess++

      res.on 'data', (chunk) =>
        file.write chunk
        len += chunk.length
        percent = Math.round len / fsize * 100
        @setProgressBar data.aid, percent

      res.on 'error', (err) ->
        console.log "Error with file '#{@params.dlPath}/#{filename}'. Aborted.", err

      res.on 'end', =>
        file.end()
        @onProcess--
        callback() if @stopFlag is false

    req.on 'error', (err) ->
      console.log "Request problem:", err.message

  loopDlFn: ->
    return if @onProcess > @params.dlThreads - 1

    track = @collectionDB[@collCurrPos++]
    currPerc = @collCurrPos * 100 / @collectionDB.length
    @circleCounter (currPerc).toFixed(1)
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
      console.log error
      return

    filename = @_getFileName track
    fs.exists "#{@params.dlPath}/#{filename}", (exists) =>
      if exists
        #console.log "#{track.artist} - #{track.title}.mp3" + ' already exists.'
        @setItemStatus 'downloaded', track.aid
        @loopDlFn()
      else
        @setItemStatus 'onprogress', track.aid
        @downloadTrack track, => @loopDlFn()

  getCollectionFromServer: (callback) ->
    options = 
      host: 'api.vk.com'
      port: 443
      path: "/method/audio.get?access_token=#{@params.token}"

    https.get options, (res) ->
      response = new String
      res.setEncoding 'utf8'
      res.on 'data', (chunk) -> response += chunk
      res.on 'end', ->
        collectionJson = (JSON.parse response).response
        callback collectionJson

  toggleDownload: =>
    if @stopFlag is false
      @stopFlag = true
    else
      @stopFlag = false
      numForLoop = @params.dlThreads - @onProcess - 1
      for [0..numForLoop]
        @loopDlFn()

  reloadCollectionDl: (folder) =>
    @stopCurrDownloads()
    @collCurrPos = 0
    @stopFlag = false
    @params.dlPath = folder
    @download()

  stopCurrDownloads: =>
    return if @onProcess is 0
    @stopFlag = true
    currPos = new Number @collCurrPos
    for [0..params.dlThreads-1]
      filename = @_getFileName @collectionDB[--currPos]
      try
        fs.unlinkSync "#{params.dlPath}/#{filename}"
      catch err
        "Error of remove file #{filename}: #{err}"

  showNoTracks: ->
    console.log "no tracks =("

