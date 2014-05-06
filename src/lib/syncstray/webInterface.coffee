document = window.document
log = window.console.log
gui = global.window.nwDispatcher.requireNwGui()

module.exports = class WebInterface
  constructor: (@observer, @params) ->
    @initTray()
    @registerDomEvents()
    @changeDlFolderLabel @params.dlPath
    @changeDlThreadsInput @params.dlThreads
    @barsWidth = document.getElementById('music-list').offsetWidth
    @syncBtn = document.getElementById 'do-sync'
    @message = document.getElementById 'message-box'

    @observer.subscribe 'setProgressBar', @setProgressBar
    @observer.subscribe 'redrawCircleCounter', @circleCounter().draw
    @observer.subscribe 'setItemStatus', @setItemStatus
    @observer.subscribe 'callbackSearch', @callbackSearch
    @observer.subscribe 'getUserData', @getUserData
    @observer.subscribe 'toggleDownload', @onSyncCheckBtn
    @observer.subscribe 'showMessage', @showMessage

  doSearch: (event) =>
    return if event.keyCode isnt 13
    req = event.target.value
    @observer.publish 'doSearch', req

  callbackSearch: ([req, id]) =>
    elClass = 'music-list-item'
    el = document.getElementById "#{elClass}_#{id}"
    @scrollTo el

  getUserData: (userData) ->
    return if not userData
    label = document.getElementById 'options_username_label'
    label.innerHTML = userData.first_name + ' ' + userData.last_name

  onSyncCheckBtn: (ev) =>
    if @syncBtn.classList.contains 'stopped'
      @syncBtn.className = 'rotate'
    else
      @syncBtn.className = 'stopped'

  registerDomEvents: (collection) ->
    document.addEventListener 'DOMContentLoaded', =>
      @syncBtn.addEventListener 'click', (ev) =>
        ev.preventDefault()
        @observer.publish 'toggleDownload'

      optionsOverlay = document.getElementById 'options'

      optionsBtn = document.getElementById 'do-options'
      optionsBtn.addEventListener 'click', (ev) =>
        ev.preventDefault()
        optionsOverlay.className = ''

      closeConfigBtn = document.getElementById 'do-options-close'
      closeConfigBtn.addEventListener 'click' , (ev) ->
        ev.preventDefault()
        optionsOverlay.className += ' hidden'

      # Options
      btn_changeDir = document.getElementById 'option_change_folder'
      btn_logout = document.getElementById 'option_logout'
      input_threads = document.getElementById 'options_threads'
      disable_scroll = document.getElementById 'option_disable_scroll'
      search_input = document.getElementById 'search_input'
      
      btn_changeDir.addEventListener 'click', @changeDlFolder
      btn_logout.addEventListener 'click', @logout
      input_threads.addEventListener 'change', @changeDlThreads
      disable_scroll.addEventListener 'click', @toggleScrollWatcher
      search_input.addEventListener 'keyup', @doSearch

  showMusicList: (collection) ->
    logo = document.getElementById 'main-logo-img'
    ul = document.getElementById 'music-list'
    frag = document.createDocumentFragment()
    for track in collection
      li = document.createElement 'li'
      li.className = 'music-list-item'
      li.id = "music-list-item_#{track.aid}"

      bar = document.createElement 'div'
      bar.className = 'music-list-item-bar'
      bar.id = "music-list-item-bar_#{track.aid}"

      checkbox = document.createElement 'checkbox'
      checkbox.className = 'music-list-item-checkbox'

      label = document.createElement 'label'
      label.className = 'music-list-item-label'
      label.innerHTML = "#{track.artist} - #{track.title}"

      li.appendChild bar
      li.appendChild checkbox
      li.appendChild label
      frag.appendChild li

    logo.className = 'hidden'
    ul.appendChild frag
    return

  scrollTo: (el) ->
    return false if not el
    offset = el.offsetTop - window.innerHeight
    document.documentElement.scrollTop = offset

  setItemStatus: ([status, id]) ->
    elClass = 'music-list-item'
    el = document.getElementById "#{elClass}_#{id}"
    if not el then return
    el.className = elClass + ' ' + status

  resetItemsStatus: ->
    elems = document.getElementsByClassName 'music-list-item'
    bars = document.getElementsByClassName 'music-list-item-bar'
    for el in elems
      el.className = 'music-list-item'
    for bar in bars
      bar.style.width = 0

  setProgressBar: ([id, percent]) =>
    el = document.getElementById "music-list-item-bar_#{id}"
    if not el
      console.error "No element with id #{id}"
      return
    el.style.width = @barsWidth * percent / 100 + 'px'
    if percent is 100 then @setItemStatus ['downloaded', id]
    if percent is 0 and @params.watch is true then @scrollTo el.parentNode.nextSibling

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
    @observer.publish 'toggleDownload'
    @chooseFolderDialog (folder) =>
      @changeDlFolderLabel folder
      global.window.localStorage.setItem 'dlPath', folder
      @resetItemsStatus()
      @reloadCollectionDl folder

  changeDlFolderLabel: (folder) ->
    label = document.getElementById 'options_change_folder_label'
    label.innerHTML = folder

  changeDlThreadsInput: (threads) ->
    input = document.getElementById 'options_threads'
    input.value = threads

  toggleScrollWatcher: (e) =>
    e.preventDefault()
    status = e.target.parentNode.classList.toggle 'checked'
    @params.watch = if status is true then false else true
    
  setDoneStatus: ->
    syncBtn = document.getElementById 'do-sync'
    syncBtn.className = 'stopped'

  circleCounter: =>
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

    changeText = (percent) =>
      text.innerHTML = if percent >= 100 then 'done' else percent + '%'
      @setDoneStatus() if percent >= 100
        
    return {
      draw: (current) ->
        ctx.putImageData imd, 0, 0
        ctx.beginPath()
        ctx.arc 30, 30, 20, -(quart), ((circ * current) / 100) - quart, false
        ctx.stroke()
        changeText current
    }

  showMessage: ([title, body]) =>
    $title = @message.getElementsByClassName('message-box-title')[0]
    $body = @message.getElementsByClassName('message-box-body')[0]
    $title.innerHTML = title
    $body.innerHTML = body
    @message.classList.remove 'hidden'


  initTray: ->
    tray = new gui.Tray
      icon: 'assets/favicon.png'
    menu = new gui.Menu

    item_show = new gui.MenuItem
      label: 'Show Program'

    item_dl = new gui.MenuItem
      type: 'checkbox'
      checked: false
      label: 'Disable download'

    item_exit = new gui.MenuItem
      label: 'Exit'

    menu.append item_show
    menu.append item_dl
    menu.append item_exit
    tray.menu = menu

    item_exit.on 'click', -> gui.App.quit()
    item_show.on 'click', -> win.show()
    item_dl.on 'click', -> observer.publish 'toggleDownload'

    @observer.subscribe 'toggleDownload', ->
      item_dl.label = if item_dl.checked then 'Disable download' else 'Enable download'
      item_dl.checked = if item_dl.checked then false else true


