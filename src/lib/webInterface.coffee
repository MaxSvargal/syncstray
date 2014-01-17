document = window.document

module.exports =
  showMusicList: (collection) ->
    ul = document.getElementById 'music-list'
    frag = document.createDocumentFragment()
    for track in collection
      li = document.createElement 'li'
      li.className = 'music-list-item'
      li.id = "music-list-item_#{track.aid}"

      bar = document.createElement 'div'
      bar.className = 'music-list-item-bar'
      bar.id = "music-list-item-bar_#{track.aid}"

      label = document.createElement 'label'
      label.className = 'music-list-item-label'
      label.innerHTML = "#{track.artist} - #{track.title}"

      li.appendChild bar
      li.appendChild label
      frag.appendChild li

    ul.appendChild frag

  setProgressBar: (id, percent) ->
    el = document.getElementById "music-list-item-bar_#{id}"
    if not el then throw new Error "No element with id #{id}"
    el.style.width = percent + '%'
    if percent is 100 then @setStatus 'downloaded', id 
    if percent is 0 then @scrollTo el.parentNode.nextSibling

  setStatus: (status, id) ->
    elClass = 'music-list-item'
    el = document.getElementById "#{elClass}_#{id}"
    el.className = elClass + ' ' + status

  scrollTo: (el) ->
    offset = el.offsetTop - window.innerHeight
    document.body.scrollTop = offset

  chooseFolderDialog: (callback) ->
    global.window.alert 'Please, select folder for upload.'
    document.addEventListener 'DOMContentLoaded', ->
      chooser = document.getElementById 'choose-folder'
      chooser.addEventListener 'change', ->
        callback this.value
      chooser.click()

  registerDomEvents: (collection) ->
    document.addEventListener 'DOMContentLoaded', ->
      syncBtn = document.getElementById 'do-sync'
      syncBtn.addEventListener 'click', (ev) ->
        ev.preventDefault()
        collection.toggleDownload()
        if syncBtn.classList.contains 'stopped'
          syncBtn.className = ''
        else
          syncBtn.className = 'stopped'

      optionsOverlay = document.getElementById 'options'

      optionsBtn = document.getElementById 'do-options'
      optionsBtn.addEventListener 'click', (ev) ->
        ev.preventDefault()
        optionsOverlay.className = ''

      closeConfigBtn = document.getElementById 'do-options-close'
      closeConfigBtn.addEventListener 'click' , (ev) ->
        ev.preventDefault()
        optionsOverlay.className += ' hidden'
