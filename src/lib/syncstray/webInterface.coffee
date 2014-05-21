document = window.document
log = window.console.log
gui = global.window.nwDispatcher.requireNwGui()

module.exports = class WebInterface
  constructor: (@observer, @params) ->
    @initTray()
    @initMessage()
    @registerDomEvents()
    @changeDlFolderLabel @params.dlPath
    @changeDlThreadsInput @params.dlThreads
    @barsWidth = document.getElementById('music-list').offsetWidth
    @syncBtn = document.getElementById 'do-sync'

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
    @observer.publish 'doSearch', [req]

  callbackSearch: ([results]) =>
    s_ul = document.getElementById 'search-list'
    s_ul.innerHTML = ''

    win_box = document.createElement 'div'
    win_box.className = 'search-list-info'
    win_box_label = document.createElement 'div'
    win_box_label.className = 'search-list-label'
    win_box_label.innerHTML = "Finded #{results.length} tracks"
    win_box_close = document.createElement 'a'
    win_box_close.href = '#'
    win_box_close.innerHTML = 'Close'
    win_box_close.className = 'search-list-close'
    win_box_close.addEventListener 'click', (e) ->
      e.preventDefault()
      s_ul.classList.add 'hidden'

    win_box.appendChild win_box_label
    win_box.appendChild win_box_close
    s_ul.appendChild win_box
    
    frag = @genListFragment results
    s_ul.appendChild frag
    s_ul.classList.remove 'hidden'

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

  genAllCheckboxSelector: ->
    allCheckbox = document.createElement 'a'
    allCheckbox.className = 'music-list-item-checkbox-all'
    allCheckbox.href = '#'
    allCheckbox.innerHTML = 'Select all'
    allCheckbox.addEventListener 'click', @checkAllHandle
    return allCheckbox

  genListFragment: (collection) ->
    frag = document.createDocumentFragment()
    allCheckbox = @genAllCheckboxSelector()
    frag.appendChild allCheckbox

    for track in collection
      li = document.createElement 'li'
      li.className = 'music-list-item'
      li.id = "music-list-item_#{track.aid}"

      bar = document.createElement 'div'
      bar.className = 'music-list-item-bar'
      bar.id = "music-list-item-bar_#{track.aid}"

      checkbox = document.createElement 'a'
      checkbox.className = 'music-list-item-checkbox'
      checkbox.href = '#'
      checkbox.setAttribute 'data-id', track.aid
      checkbox.addEventListener 'click', @checkboxClickHandle

      label = document.createElement 'label'
      label.className = 'music-list-item-label'
      label.innerHTML = "#{track.artist} - #{track.title}"

      li.appendChild bar
      li.appendChild checkbox
      li.appendChild label
      frag.appendChild li
    return frag

  checkAllHandle: (e) =>
    e.preventDefault()
    els = document.getElementsByClassName 'music-list-item-checkbox'
    el.classList.add 'checked' for el in els

  checkboxClickHandle: (e) =>
    e.preventDefault()
    $el = e.target
    $el.classList.toggle 'checked'
    if $el.classList.contains 'checked'
      @observer.publish 'downloadTrack', [$el.getAttribute('data-id')]

  showMusicList: (collection) ->
    logo = document.getElementById 'main-logo-img'
    logo.className = 'hidden'
    ul = document.getElementById 'music-list'
    frag = @genListFragment collection
    ul.appendChild frag
    return

  scrollTo: (el) ->
    return false if not el
    $box = document.getElementById 'music-list'
    $box.scrollTop = el.offsetTop - $box.clientHeight + 75

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
      @observer.publish 'reloadCollectionDl', [folder]

  changeDlThreads: (e) =>
     @observer.publish 'changeDlThreads', [e.target.value]

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

  initMessage: ->
    @$message = document.getElementById 'message-box'
    @$message_title = @$message.getElementsByClassName('message-box-title')[0]
    @$message_body = @$message.getElementsByClassName('message-box-body')[0]
    @$message_ok_btn = document.getElementById 'message-ok-btn'
    @$message_cancel_btn = document.getElementById 'message-cancel-btn'

    @$message_ok_btn.addEventListener 'click', (e) =>
      e.preventDefault()
      @$message.classList.add 'hidden'

    @$message_cancel_btn.addEventListener 'click', (e) =>
      e.preventDefault()
      @$message.classList.add 'hidden'

  showMessage: (params) =>
    @$message_title.innerHTML = params.title if params.title
    @$message_body.innerHTML = params.body if params.body
    @$message_ok_btn.innerHTML = params.okBtnLabel if params.okBtnLabel

    @$message.classList.remove 'hidden'
    @$message_ok_btn.addEventListener 'click', =>
      params.onOkBtnClick() if params.onOkBtnClick

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


