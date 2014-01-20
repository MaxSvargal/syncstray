https = require 'https'
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
    hash = @window.location.hash
    code = hash.match /#code=(\w+)/, hash
    if code
      @close()
      callback code[1]
    else
      @show()

module.exports = (params) ->
  initialize: (callback) ->
    getPermissions params, (code) ->
      params.code = code
      getTokenFromServer params, (token) ->
        callback "Getting token fail." if token.type is 'error'
        console.log "Get ready with token ", token
        callback token if typeof token is 'string'
