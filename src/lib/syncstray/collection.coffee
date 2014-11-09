'use strict'

http = require 'http'
https = require 'https'
fs = require 'fs'
gui = global.window.nwDispatcher.requireNwGui()
path = require 'path'
Datastore = require 'nedb'

module.exports = class Collection
  constructor: (@observer, @params) ->
    @db = new Datastore { filename: path.join(gui.App.dataPath, 'collection.db'), autoload: true }
    @db.ensureIndex { fieldName: 'aid', unique: true }
    #/Users/user/Library/Application Support/syncstray/collection.db
    @stopFlag = false
    @onProcess = 0
    @collCurrPos = 0
    @collectionDB = []

    @observer.subscribe 'doSearch', @doSearch
    @observer.subscribe 'toggleDownload', @toggleDownload
    @observer.subscribe 'stopDownload', @stopCurrDownloads
    @observer.subscribe 'reloadCollectionDl', @reloadCollectionDl
    @observer.subscribe 'downloadTrack', @downloadSingleTrack
    @observer.subscribe 'changeDlThreads', @changeDlThreads

  get: (callback) ->
    @getCollectionFromServer (dl_collection) =>
      @saveCollection dl_collection
      callback dl_collection

  download: (path) ->
    if path then @params.dlPath = path
    numForLoop = @params.dlThreads - @onProcess - 1
    for [0..numForLoop]
      @loopDlFn()

  saveCollection: (data) ->
    @collectionDB = data
    @showNoTracks() if data.length is 0

  changeDlThreads: ([threads]) =>
    window.localStorage.setItem 'dlThreads', threads
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
    try
      file = fs.createWriteStream "#{@params.dlPath}/#{filename}", { flags: 'a' }
      file.on 'error', (e) ->
        console.log e
        callback() if @stopFlag is false
    catch
      console.error "Error write file #{filename}. Ignoring."
      callback() if @stopFlag is false 
      return

    finally
      req = http.get data.url, (res) =>
        fsize = res.headers['content-length']
        len = 0
        @onProcess++

        res.on 'data', (chunk) =>
          file.write chunk
          len += chunk.length
          percent = Math.round len / fsize * 100
          @observer.publish 'setProgressBar', [data.aid, percent]

        res.on 'error', (err) ->
          console.log "Error with file '#{@params.dlPath}/#{filename}'. Aborted.", err
          callback() if @stopFlag is false

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
    @observer.publish 'redrawCircleCounter', (currPerc).toFixed(1)
    return if not track
    # Trim strings for corrective filename
    try
      filteredSymbols = [
        [/\s{2,}/g, ' ']
        [/[><|"\?\*:\/\\]/g, '']
      ]
      for symbol in filteredSymbols
        track.artist = track.artist.replace symbol[0], symbol[1]
        track.title = track.title.replace symbol[0], symbol[1]
    catch error
      console.error error
      return

    filename = @_getFileName track
    try
      fs.exists "#{@params.dlPath}/#{filename}", (exists) =>
        if exists
          #console.log "#{track.artist} - #{track.title}.mp3" + ' already exists.'
          @observer.publish 'setItemStatus', ['downloaded', track.aid]
          @loopDlFn()
        else
          @observer.publish 'setItemStatus', ['onprogress', track.aid]
          @downloadTrack track, => @loopDlFn()
    catch err
      console.error err

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
    for [0..@params.dlThreads-1]
      filename = @_getFileName @collectionDB[--currPos]
      try
        fs.unlinkSync "#{params.dlPath}/#{filename}"
      catch err
        "Error of remove file #{filename}: #{err}"

  showNoTracks: ->
    console.log "no tracks =("

  doSearch: ([req]) =>
    results = []
    regexp = new RegExp "(?=#{req}){3,}.*$", 'i'
    @collectionDB.forEach (track) =>
      s_artist = track.artist.search regexp
      s_title = track.title.search regexp

      if s_artist != -1 or s_title != -1
        results.push track
        
    @observer.publish 'callbackSearch', [results]

  downloadSingleTrack: (id) =>
    for track in @collectionDB
      if track.aid is parseInt id
        @downloadTrack track, -> null
        return

