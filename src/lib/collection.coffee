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
    #/Users/user/Library/Application Support/syncstray/collection.db
    @stopFlag = false
    @onProcess = 0
    @collCurrPos = 0
    @collectionDB = []
    @subscribers = []
    @counter = @circleCounter()

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

  setStatus = (status, id) ->
    console.log "SET", status, id

  subscribe: (method, callback) ->
    @subscribers.push {'method': method, 'callback': callback}

  setProgressBar: (aid, percent) =>
    subscriber.callback(aid, percent) for subscriber in @subscribers

  saveCollection: (data, callback) ->
    @db.insert data, (err) ->
      if err then throw err
      console.log "Music list cached."
      callback()

  getCachedCollection: (callback) ->
    @db.find {}, (err, collection) ->
      callback collection

  _getFileName: (data) ->
    "#{data.artist} - #{data.title}.mp3"

  downloadTrack: (data, callback) =>
    filename = @_getFileName data
    file = fs.createWriteStream "#{@params.dlPath}/#{filename}", { flags: 'a' }
    onProcess = @onProcess
    setProgressBar = @setProgressBar
    stopFlag = @stopFlag

    http.get data.url, (res) ->
      fsize = res.headers['content-length']
      len = 0
      onProcess++

      res.on 'data', (chunk) ->
        file.write chunk
        len += chunk.length
        percent = Math.round len / fsize * 100
        setProgressBar data.aid, percent

      res.on 'error', ->
        console.log "Error with file '#{@params.dlPath}/#{filename}'. Aborted."

      res.on 'end', ->
        file.end()
        onProcess--
        callback() if @stopFlag is false

  loopDlFn: ->
    track = @collectionDB[@collCurrPos++]
    currPerc = @collCurrPos * 100 / @collectionDB.length
    @counter.draw (currPerc).toFixed(1)
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
        console.log "#{track.artist} - #{track.title}.mp3" + ' already exists.'
        setStatus 'downloaded', track.aid
        @loopDlFn()
      else
        setStatus 'onprogress', track.aid
        @downloadTrack track, => @loopDlFn()

  getCollectionFromServer: (callback) ->
    getCachedCollection = @getCachedCollection
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

  toggleDownload: ->
    if @stopFlag is false
      @stopFlag = true
    else
      @stopFlag = false
      numForLoop = @params.dlThreads - @onProcess - 1
      for [0..numForLoop]
        @loopDlFn()

  stopCurrDownloads: (callback) ->
    @toggleDownload()
    currPos = new Number @collCurrPos
    for [0..params.dlThreads-1]
      filename = @_getFileName @collectionDB[--currPos]
      try
        fs.unlinkSync "#{params.dlPath}/#{filename}"
      catch err
        "Error of remove file #{filename}: #{err}"
    callback()

  circleCounter: ->
    setDoneStatus = @setDoneStatus
    text = window.document.getElementById 'counter-label'
    canvas = window.document.getElementById 'counter'
    ctx = canvas.getContext '2d'
    circ = Math.PI * 2
    quart = Math.PI / 2

    ctx.beginPath()
    ctx.strokeStyle = '#fff'
    ctx.lineCap = 'square'
    ctx.closePath()
    ctx.fill()
    ctx.lineWidth = 6.0

    imd = ctx.getImageData 0, 0, 60, 60

    changeText = (percent) ->
      text.innerHTML = percent + '%'
      setDoneStatus() if percent is 100
        
    return {
      draw: (current) ->
        ctx.putImageData imd, 0, 0
        ctx.beginPath()
        ctx.arc 30, 30, 20, -(quart), ((circ * current) / 100) - quart, false
        ctx.stroke()
        changeText current
    }

  showNoTracks: ->
    console.log "no tracks =("
