document = window.document

module.exports =
  showMusicList: (musicListData) ->
    ul = document.getElementById 'music-list'
    frag = document.createDocumentFragment()
    for track in musicListData
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


  setStatus: (status, id) ->
    elClass = 'music-list-item'
    el = document.getElementById "#{elClass}_#{id}"
    el.className = elClass + ' ' + status