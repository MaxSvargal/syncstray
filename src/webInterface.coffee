document = window.document

module.exports =
  showMusicList: (musicListData) ->
    ulEl = document.getElementById 'music-list'
    frag = document.createDocumentFragment()
    for track in musicListData
      liEl = document.createElement 'li'
      liEl.className = 'music-list-item'
      liEl.id = "music-list-item_#{track.aid}"
      liEl.innerHTML = "#{track.artist} - #{track.title}"
      frag.appendChild liEl

    ulEl.appendChild frag