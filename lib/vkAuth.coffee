https = require 'https'

getToken = (params, callback) ->
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
        throw json.error

getPermissions = (params, gui, callback) ->
  url = "https://oauth.vk.com/authorize?client_id=#{params.appID}&scope=audio&response_type=code"
  childWindow = gui.Window.open url, 
    width: 607
    height: 312

  childWindow.on 'loaded', ->
    hash = this.window.location.hash
    code = hash.match /#code=(\w+)/, hash
    if code[1]
      this.close()
      callback code[1]
    else
      this.reload()


module.exports = (params, gui) ->
  initialize: (callback) ->
    getPermissions params, gui, (code) ->
      params.code = code
      getToken params, (token) ->
        callback token