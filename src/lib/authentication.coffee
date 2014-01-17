https = require 'https'
async = require 'async'
gui = global.window.nwDispatcher.requireNwGui()
path = require 'path'
Datastore = require 'nedb'

getTokenFromServer = (params, callback) ->
  options =
    host: 'oauth.vk.com'
    port: 443
    path: "/access_token?client_id=#{params.appID}" + 
      "&client_secret=#{params.appSecret}" +
      "&code=#{params.code}"

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

getPermissions = (params, callback) ->
  url = "https://oauth.vk.com/authorize?client_id=#{params.appID}&scope=audio&response_type=code"
  childWindow = gui.Window.open url, {
    width: 800
    height: 600
    position: "center"
    toolbar: false
  }
  childWindow.hide()

  childWindow.on 'loaded', ->
    hash = this.window.location.hash
    code = hash.match /#code=(\w+)/, hash
    if code
      this.close()
      callback code[1]
    else
      this.show()

module.exports = (params) ->
  initialize: (callback) ->
    async.waterfall [
      (callback) ->
        getPermissions params, (code) ->
          #saveAuthCode code, ->
          callback null, code
      (code, callback) ->
        params.code = code
        getTokenFromServer params, (token) ->
          callback "Getting token fail." if token.type is 'error'
          callback null, token
    ], (err, token) ->
      console.log err if err
      console.log "Get ready with token ", token
      callback token if typeof token is 'string'
