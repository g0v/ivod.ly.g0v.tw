angular.module 'app.controllers' <[ng app.cinema]>
.run <[$rootScope]> ++ ($rootScope) ->
.controller AppCtrl: <[$scope $location $rootScope $state]> ++ (s, $location, $rootScope, $state) ->
  s <<< {$location}
  s.$watch '$location.path()' (activeNavId or '/') ->
    s <<< {activeNavId}
  s.getClass = (id) ->
    if s.activeNavId.substring 0 id.length is id
      'active'
    else
      ''
  s <<< {$state}
  s.$watch '$state.current.name', (name) ->
    if name == 'cinema.view'
      $ \svg .show!
      $ \#cinema-curtain .show!
      $ \body .addClass \blackbg
    else
      $ \svg .hide!
      $ \#cinema-curtain .hide!
      $ \body .removeClass \blackbg
    if name == 'vlist' => $ \body .addClass \blackbg
.controller About: <[$rootScope $http]> ++ ($rootScope, $http) ->
    $rootScope.activeTab = \about

.controller Danmaku: <[$scope DanmakuStore $timeout DanmakuPaper PipeService DanmakuStats]> ++ ($scope, DanmakuStore, $timeout, DanmakuPaper, PipeService, DanmakuStats) ->
  $scope.statsData = []
  PipeService.on \player.init (v) ->
    $scope.player = v
    DanmakuStats.queryAll $scope.current-video-id, ->
      start = $scope.cliptime / 10000
      temp = []
      if it
        angular.forEach it.val!, (val, key) ->
          offset = val.offset / 10000 - start
          index = ~~offset
          temp[index] = 0
          switch val.type
          case \egg || \shoe || \melon || \banner
            temp[index] -= 1
          case \flower || \boat || \duck || \net
            temp[index] += 1
        angular.forEach temp, (value, index) ->
          if !isNaN value => $scope.statsData.push [index, value]
        $scope.render-stats $scope.statsData
  $scope.$on 'danmaku_added', (ev, danmaku)->
    if $scope.cliptime => now = $scope.cliptime*1000
    else => now = new Date! .getTime! - 2000
    if danmaku.timestamp >= now
      switch danmaku.type
      case \content
        if $scope.cliptime => $timeout (DanmakuPaper.poptext danmaku.text, '#fff', 30, 5000), danmaku.timestamp - $scope.cliptime
        else => DanmakuPaper.poptext danmaku.text, '#fff', 30, 5000
      case \attack
        {action, mx, my, ex, ey, sy} = danmaku
        DanmakuPaper.throwEgg action, mx, my, ex, ey, sy
      case \protect
        DanmakuPaper.protect danmaku.action
  $scope.addComment = ->
    if $scope.cliptime => timestamp = $scope.getTimestamp!* 1000
    else => timestamp = new Date! .getTime!
    created_at = new Date! .getTime!
    if $scope.isplaying!
      DanmakuStore.store $scope.current-video-id, {text: $scope.newComment, timestamp: timestamp, created_at: created_at, type: \content}
    else
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#fff', 30, 5000

#.controller EggNinja: <[$scope DanmakuStore DanmakuPaper PipeService DanmakuStats]> ++ ($scope, DanmakuStore, DanmakuPaper, PipeService, DanmakuStats) ->
  player = $ \#cinema-player
  crosshair = $ \#crosshair
  #egg = $ \#egg
  [w,h] = [player.width!, player.height!]
  {top:y, left: x} = player.offset!
  eggninja = $ \#eggninja
  eggninja.offset {top: y, left: x}
  eggninja.css  width: "#{w}px", height: "#{h - 30}px"
  eggninja.on \click (e) ->
    if !$scope.isplaying!
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#fff', 30, 5000
      return
    player = $ \#video-wrapper
    sy = $(document.body)scrollTop!
    {clientX: mx, clientY: my} = e
    type = <[egg shoe melon]>[parseInt(Math.random!* *)]
    [ww, wh] = [$(document.body)width!, $(window)height!]
    [ex, ey] = [if Math.random!>0.5 => ww else 0, my + parseInt((wh - my ) / 2)]
    timestamp = new Date! .getTime!
    created_at = new Date! .getTime!
    DanmakuStore.store $scope.current-video-id, {action: type, mx: mx, my:my, ex: ex, ey: ey, sy: sy, timestamp: timestamp, created_at: created_at, type: \attack}
    DanmakuStats.updateTotal $scope.current-video-id, type
    DanmakuPaper.throwEgg type, mx, my, ex, ey, sy
    offset = new Date! .getTime!
    DanmakuStats.updateQueue $scope.current-video-id, {offset: offset, type: type}

  eggninja.on \mousemove (e) ->
    {clientX: mx, clientY: my} = e
    sy = $(window)scrollTop!
    player.parent!parent!parent!trigger \mousemove
    crosshair.offset top: my - 100 + sy, left: mx - 100

  $scope.raise-net = (e) ->
    if !$scope.isplaying!
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#fff', 30, 5000
      return
    DanmakuPaper.protect \raise-net
    timestamp = new Date! .getTime!
    created_at = new Date! .getTime!
    DanmakuStore.store $scope.current-video-id, {action: \raise-net, timestamp: timestamp, created_at: created_at, type: \protect}
    DanmakuStats.updateTotal $scope.current-video-id, \net
    offset = new Date! .getTime!
    DanmakuStats.updateQueue $scope.current-video-id, {offset: offset, type: \net}

  $scope.objection = (e, type) ->
    if !$scope.isplaying!
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#fff', 30, 5000
      return
    DanmakuPaper.protect type
    timestamp = new Date! .getTime!
    created_at = new Date! .getTime!
    DanmakuStore.store $scope.current-video-id, {action: \white-banner, timestamp: timestamp, created_at: created_at, type: \protect}
    DanmakuStats.updateTotal $scope.current-video-id, \banner
    offset = new Date! .getTime!
    DanmakuStats.updateQueue $scope.current-video-id, {offset: offset, type: \banner}

  $scope.flower = (e, type) ->
    if !$scope.isplaying!
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#fff', 30, 5000
      return
    if type=='boat' and Math.random!>0.7 => type = 'duck'
    DanmakuPaper.protect type
    timestamp = new Date! .getTime!
    created_at = new Date! .getTime!
    DanmakuStore.store $scope.current-video-id, {action: type, timestamp: timestamp, created_at: created_at, type: \protect}
    DanmakuStats.updateTotal $scope.current-video-id, type
    offset = new Date! .getTime!
    DanmakuStats.updateQueue $scope.current-video-id, {offset: offset, type: type}

  $scope.render-stats = (data) ->
    root = $ \#action-stats
    [w,h] = [root.width!, root.height!]
    svg = d3.select \#action-stats .append \svg .attr \width \100% .attr \height  \100% .style \position \absolute

    #data = [[i, 1 - 2*Math.random!] for x,i in[ 0 to 100]]
    x = d3.scale.linear!range [0,w] .domain [0,d3.max(data.map(-> it.0))]
    y = d3.scale.linear!range [0,h] .domain [1,-1]
    svg.append \rect .attr \x 0 .attr \y 0 .attr \width w .attr \height h/2 .style \fill \#f99
    svg.append \rect .attr \x 0 .attr \y h/2 .attr \width w .attr \height h .style \fill \#9f9
    svg.append \path .attr \class \line
      .attr \d ->
        #"M0 #{h/2}" + ([[i,d] for d,i in data]map(->"L#{x it.0} #{y it.1}")join "") + "L #{w} #{h/2}"
        "M0 #{h/2}" + (data.map(->"L#{x it.0} #{y it.1}")join "") + "L #{w} #{h/2}"
  #$scope.render-stats!
  $scope.$watch 'player' -> if it => PipeService.dispatchEvent \player.init, it
  PipeService.on \player.settime ->
    console.log "play time set to #it"
    $scope.player.setCurrentTime it

.controller vlist: <[$scope $http LYModel]> ++ ($scope, $http, LYModel) ->
  $scope.positive = true;
  $scope.switch = -> $scope.positive = !$scope.positive
  $scope.videos = []
  sk = 0
  $scope.loading = 0
  $scope.load-list = (query={}, cb)->
    $scope.loading = 1
    {entries,paging} <- LYModel.get "ivod" {params: {sk}} .success
    $scope.videos ++= entries
    sk += paging.l
    $scope.loading = 0
  $scope.load-list!

  /*$scope.do3d = ->
    list = $ \.video.wrapper
    for item in list
      item = $ item
      [w,h] = [$ document.body .width!, $ document.body .height!]
      {left:x, top:y} = item.offset!
  */

  $ document .on \scroll (e) ->
    t = $ document.body .scrollTop!
    [w,h] = [$ document.body .width!, $ document.body .height!]
    if t > $(\#vlist)height! * 0.7 and !$scope.loading => $scope.$apply -> $scope.load-list!
    #$ \#vlist .css \-webkit-perspective \100px
    $ \#vlist .css \-webkit-perspective-origin "50% #{t}px"
    #  .css \-webkit-perspective \1000px
    /*
    for item in list
      item = $ item
      {left:x, top:y} = item.offset!
      x = x + item.outerWidth!/2
      item.css \-webkit-transform "translateZ(#{(Math.abs(x - w/2) + Math.abs(y - t - h/2))/5}px) rotateY(#{-(x - w/2)/30}deg)"
      #item.css \-webkit-transform "rotateX(#{((y - t) - h/2)/10}deg) translateZ(#{(Math.abs(x - w/2)+Math.abs(y - t - h/2))/5}px)"
      #item.css \-webkit-transform "rotateY(#{(x - w/2) / 10}deg) rotateX(#{((y - t) - h/2)/10}deg)"
    */

.controller mlylist: <[$scope $http]> ++ ($scope, $http) ->
  $scope.mly = []
  $scope.sortBy = 'name'
  $http.get \/mly-8.json .success ->
    $scope.mly = it
    setTimeout (->
      $ \#mly-content .isotope do
         itemSelector: \.mlyitem
         layoutMode: \fitRows
         getSortData:
           name: (e) ~> $scope.mly[+(e.attr \data-id)].name
           party: (e) ~> $scope.mly[+(e.attr \data-id)].caucus
           constituency: (e) ~> $scope.mly[+(e.attr \data-id)].constituency?.1
         sortBy: \name
      $scope.inited = true
    ), 0
    $scope.$watch "sortBy", ~>
      if $scope.inited =>
        $ \#mly-content .isotope do
          sortBy: $scope.sort-by
