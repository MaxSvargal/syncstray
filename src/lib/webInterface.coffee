document = window.document

module.exports = class WebInterface
  constructor: ->
    @subscribers = []
    @circleCounter = @circleCounterCounstructor().draw
    @registerDomEvents()

  subscribe: (method, callback) ->
    @subscribers.push {'method': method, 'callback': callback}

  toggleDownload: ->
    subscriber.callback() for subscriber in @subscribers when subscriber.method is 'toggleDownload'

  reloadCollectionDl: ->
    subscriber.callback() for subscriber in @subscribers when subscriber.method is 'reloadCollectionDl'

  logout: (callback) =>
    for subscriber in @subscribers when subscriber.method is 'logout'
      subscriber.callback (callback) ->
        console.log callback

  registerDomEvents: (collection) ->
    document.addEventListener 'DOMContentLoaded', =>
      syncBtn = document.getElementById 'do-sync'
      syncBtn.addEventListener 'click', (ev) =>
        ev.preventDefault()
        @toggleDownload()
        if syncBtn.classList.contains 'stopped'
          syncBtn.className = 'rotate'
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

      # Options
      btn_changeDir = document.getElementById 'option_change_folder'
      btn_logout = document.getElementById 'option_logout'
      btn_threads = document.getElementById 'options_threads'
      
      btn_changeDir.addEventListener 'click', @changeDlFolder
      btn_logout.addEventListener 'click', @logout

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
    return

  scrollTo: (el) ->
    offset = el.offsetTop - window.innerHeight
    document.body.scrollTop = offset

  setItemStatus: (status, id) ->
    elClass = 'music-list-item'
    el = document.getElementById "#{elClass}_#{id}"
    el.className = elClass + ' ' + status

  setProgressBar: (id, percent) =>
    el = document.getElementById "music-list-item-bar_#{id}"
    if not el then throw new Error "No element with id #{id}"
    el.style.width = percent + '%'
    if percent is 100 then @setItemStatus 'downloaded', id 
    if percent is 0 then @scrollTo el.parentNode.nextSibling

  showNoTracks: ->
    ul = document.getElementById 'music-list'
    el = document.createElement 'div'
    el.className = 'message-notracks'
    el.innerHTML = 'No tracks in your playlist :('
    ul.appendChild el

  chooseFolderDialog: (callback) ->
    chooser = document.getElementById 'choose-folder'
    chooser.addEventListener 'change', ->
      callback @value
    chooser.click()

  changeDlFolder: =>
    @toggleDownload()
    @chooseFolderDialog (folder) =>
      global.window.localStorage.setItem 'dlPath', folder
      @reloadCollectionDl()
    
  setDoneStatus: ->
    syncBtn = document.getElementById 'do-sync'
    syncBtn.className = 'stopped'

  circleCounterCounstructor: =>
    text = global.window.document.getElementById 'counter-label'
    canvas = global.window.document.getElementById 'counter'
    ctx = canvas.getContext '2d'
    circ = Math.PI * 2
    quart = Math.PI / 2

    ctx.beginPath()
    ctx.strokeStyle = '#fff'
    ctx.lineCap = 'square'
    ctx.closePath()
    ctx.fill()
    ctx.lineWidth = 5.0

    imd = ctx.getImageData 0, 0, 60, 60

    changeText = (percent) ->
      text.innerHTML = percent + '%'
      @setDoneStatus() if percent is 100
        
    return {
      draw: (current) ->
        ctx.putImageData imd, 0, 0
        ctx.beginPath()
        ctx.arc 30, 30, 20, -(quart), ((circ * current) / 100) - quart, false
        ctx.stroke()
        changeText current
    }