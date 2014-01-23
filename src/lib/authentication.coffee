https = require 'https'
gui = global.window.nwDispatcher.requireNwGui()
path = require 'path'
fs = require 'fs'

module.exports = class Auth
  constructor: (@params) ->
    return

  login: (callback) ->
    @getPermissions (code) =>
      @setCode code
      @getTokenFromServer code, (token) ->
        callback "Getting token fail." if token.type is 'error'
        console.log "Get ready with token ", token
        if typeof token is 'string'
          @token = token
          callback token
          false

  logout: (callback) =>
    fs.unlink gui.App.dataPath + '/cookies', (err) ->
      console.log err.message if err
      @setCode null
      @login()
      callback()

  getPermissions: (callback) ->
    # If permission code is saved, return it
    code = getCode()
    callback code if code
    return

    url = "https://oauth.vk.com/authorize?client_id=#{@params.appID}&scope=audio&response_type=code"
    childWindow = gui.Window.open url, {
      width: 800
      height: 600
      position: "center"
      toolbar: false
    }
    childWindow.hide()

    childWindow.on 'loaded', ->
      hash = @window.location.hash
      code = hash.match(/#code=(\w+)/, hash)[1]
      if code
        @close()
        callback code
      else
        @show()

  getTokenFromServer: (code, callback) ->
    options =
      host: 'oauth.vk.com'
      port: 443
      path: "/access_token?client_id=#{@params.appID}&client_secret=#{@params.appSecret}&code=#{code}"

    https.get options, (res) ->
      response = new String
      res.setEncoding 'utf8'
      res.on 'data', (chunk) -> response += chunk
      res.on 'end', ->
        json = JSON.parse response
        if json.access_token
          console.log "Auth successed!"
          callback json.access_token
        else
          callback { type: 'error', message: json.error }

  setCode: (code) ->
    global.window.localStorage.setItem 'authCode', code

  getCode: ->
    global.window.localStorage.getItem 'authCode'