angular.module 'app.services' []
.service 'DanmakuStats': <[$q]> ++ ($q) ->
  root = new Firebase 'https://ivod.firebaseio.com/'
  update: (vid, type) ->
    video = root.child("videos/#vid")
    stats = video.child('stats')
    stats.once 'value' ->
      obj = {egg: 0, shoe: 0, melon: 0, net: 0, banner: 0, flower: 0, boat: 0, duck: 0}
      obj[type] = 1
      if it.val! === null => stats.set obj
      else
        stats.child(type).once 'value' ->
          stats.child(type).set it.val! + 1
.service 'DanmakuPaper': ->
  player = $ \#cinema-player
  {left: x, top: y} = player.offset!
  paper = Raphael x, y, player.width!, player.height! - 30
  has-net = false
  net-handle = null
  poptext: (text, color, size, ms) ->
    paper.text 30, Math.floor(Math.random!*300), text
      .attr {'font-size': size, 'fill': color}
      .animate {x: 2*paper.width}, ms
  throwEgg: (type, mx, my, ex, ey, sy) ->
    egg = $ \<div></div>
    egg.addClass "rotate egg"
    egg.css \background-image, "url(/img/#{type}.png)"
    $ document.body .append egg
    egg.offset left: ex - 50, top: ey - 50 + sy .animate left: mx - 50, top: my - 50 + sy
      ..animate left: mx - 50, top: my + 50 + sy if !has-net
      ..animate left: ex - 50, top: ey - 50 + sy if has-net
      ..fadeOut!
  protect: (type) ->
    wrapper = $ \#video-wrapper
    {top:y, left: x} = wrapper.offset!
    [w, h] = [wrapper.width!, wrapper.height!]
    egg = $ \<div></div>
    switch type
    case \raise-net
      has-net := true
      if net-handle => clearTimeout net-handle
      net-handle := setTimeout (->
        has-net := false
        net-handl = null
      ), 3000
      egg.addClass \raise-net
      $ document.body .append egg
      egg.offset left: x, top: y - 150 .animate top: y  .delay 3000 .fadeOut!
    case \white-banner
      egg.addClass \white-banner .text "司法不公  政治迫害"
      $ document.body .append egg
      egg.offset left: x, top: y - 150 .animate top: y - 50  .delay 500 .fadeOut!
    default
      egg.addClass type
      $ document.body .append egg
      egg.offset left: x - 100, top: y + h - 200 .animate left: x + parseInt(w / 2) - 100  .delay 500 .fadeOut!

.service 'DanmakuStore': <[$q]> ++ ($q) ->
  root = new Firebase 'https://ivod.firebaseio.com/'
  store: (vid, obj) ->
    video = root.child("videos/#vid")
    newentry = video.child('danmaku').push!
    newentry.setWithPriority obj, obj.timestamp
  subscribe: (vid, cb) ->
    # also: 'child_changed', 'child_removed' or 'child_moved'
    # use them to maintain list of upcoming danmaku
    root.child("videos/#vid/danmaku").on \child_added, cb
    null
  unsubscribe: (vid) ->
    root.child("videos/#vid/danmaku").off \child_added
.service 'LYModel': <[$q $http $timeout]> ++ ($q, $http, $timeout) ->
    base = 'http://api-beta.ly.g0v.tw/v0/collections/'
    _model = {}

    localGet = (key) ->
      deferred = $q.defer!
      promise = deferred.promise
      promise.success = (fn) ->
        promise.then fn
      promise.error = (fn) ->
        promise.then fn
      $timeout ->
        console.log \useLocalCache
        deferred.resolve _model[key]
      return promise

    wrapHttpGet = (key, url, params) ->
      {success, error}:req = $http.get url, params
      req.success = (fn) ->
        rsp <- success
        console.log 'save response to local model'
        _model[key] = rsp
        fn rsp
      req.error = (fn) ->
        rsp <- error
        fn rsp
      return req

    return do
      get: (path, params) ->
        url = base + path
        key = if params => url + JSON.stringify params else url
        key -= /\"/g
        return if _model.hasOwnProperty key
          localGet key
        else
          wrapHttpGet key, url, params

.factory \PipeService, -> do
  listeners: {}
  dispatchEvent: (n, v) -> (@listeners[n] or [])map -> it v
  on: (n, cb) -> @listeners.[][n].push cb
