https = require 'https'
gui = global.window.nwDispatcher.requireNwGui()
path = require 'path'
fs = require 'fs'

module.exports = class Auth
  constructor: (@params) ->
    @userData = null
    @subscribers = []
    return

  subscribe: (method, callback) ->
    @subscribers.push {'method': method, 'callback': callback}

  login: (callback) ->
    @getPermissions (code) =>
      @getTokenFromServer code, (token) =>
        callback "Getting token fail." if token.type is 'error' or token.error
        console.log "Get ready with token ", token
        @token = token
        @getUserData()
        if typeof token is 'string'
          callback token
          return

  logout: =>
    fs.unlink gui.App.dataPath + '/cookies', (err) =>
      console.log err.message if err
      window.alert "Please, restart the application for re-login."

  getPermissions: (callback) =>
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
      code = hash.match /#code=(\w+)/, hash
      if code
        @close()
        callback code[1]
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

  getUserFromServer: (callback) ->
    options = 
      host: 'api.vk.com'
      port: 443
      path: "/method/users.get?access_token=#{@token}"

    https.get options, (res) ->
      response = new String
      res.setEncoding 'utf8'
      res.on 'data', (chunk) -> response += chunk
      res.on 'end', ->
        @userData = (JSON.parse response).response
        callback @userData[0]

  getUserData: ->
    if @userData is null
      @getUserFromServer (userData) =>
        for subscriber in @subscribers when subscriber.method is 'getUserData'
          subscriber.callback(userData) 
        return
    else
      subscriber.callback(@userData) for subscriber in @subscribers when subscriber.method is 'getUserData'
      return
        