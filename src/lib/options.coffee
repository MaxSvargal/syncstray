document = window.document

module.exports = (collection, webI) ->
  changeDir =  ->
    collection.toggleDownload()
    webI.chooseFolderDialog (folder) ->
      global.window.localStorage.setItem 'dlPath', folder
      collection.downloadCollection folder
      collection.toggleDownload()

  logout = ->
    collection.toggleDownload()
    auth.logout()
    ###
      auth.initialize (token) ->
        collection.getCollectionFromServer (music) ->
          webI.showMusicList music
          collection.downloadCollection()
          return
    ###

  initialize: ->
    btn_changeDir = document.getElementById 'option_change_folder'
    btn_logout = document.getElementById 'option_logout'
    btn_threads = document.getElementById 'options_threads'
    
    btn_changeDir.addEventListener 'click', changeDir, false
    btn_logout.addEventListener 'click', logout, false
