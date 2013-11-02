angular.module 'app.controllers' <[ng app.cinema]>
.run <[$rootScope]> ++ ($rootScope) ->
.controller AppCtrl: <[$scope $location $rootScope]> ++ (s, $location, $rootScope) ->

  s <<< {$location}
  s.$watch '$location.path()' (activeNavId or '/') ->
    s <<< {activeNavId}

  s.getClass = (id) ->
    if s.activeNavId.substring 0 id.length is id
      'active'
    else
      ''

.controller About: <[$rootScope $http]> ++ ($rootScope, $http) ->
    $rootScope.activeTab = \about

.controller Danmaku: <[$scope DanmakuStore $timeout DanmakuPaper PipeService]> ++ ($scope, DanmakuStore, $timout, DanmakuPaper, PipeService) ->

  $scope.comments = []
  PipeService.on \player.init (v) ->
    console.log " I got #{v}!" # sample code

  $scope.$on 'danmaku_added', (ev, danmaku)->
    now = new Date! .getTime! - 2000
    if danmaku.timestamp >= now
      switch danmaku.type 
      case \content  
        $scope.comments.push danmaku
        DanmakuPaper.poptext danmaku.text, '#888', 30, 5000
      case \attack
        {action, mx, my, ex, ey, sy} = danmaku
        DanmakuPaper.throwEgg action, mx, my, ex, ey, sy
      case \protect
        DanmakuPaper.protect danmaku.action
  $scope.addComment = ->
    timestamp = new Date! .getTime!
    created_at = new Date! .getTime!
    if $scope.isplaying! 
      DanmakuStore.store $scope.current-video-id, {text: $scope.newComment, timestamp: timestamp, created_at: created_at, type: \content} 
    else
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#888', 30, 5000

.controller vlist: <[$scope $http]> ++ ($scope, $http) ->
  $scope.blah = "hello world"
.controller mlylist: <[$scope $http]> ++ ($scope, $http) ->
  $scope.blah = "hello world"

.controller EggNinja: <[$scope DanmakuStore DanmakuPaper PipeService DanmakuStats]> ++ ($scope, DanmakuStore, DanmakuPaper, PipeService, DanmakuStats) ->
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
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#888', 30, 5000  
      return  
    player = $ \#video-wrapper
    sy = $(document.body)scrollTop!
    {clientX: mx, clientY: my} = e
    type = <[egg shoe melon]>[parseInt(Math.random!*3)]
    [ww, wh] = [$(document.body)width!, $(window)height!]
    [ex, ey] = [if Math.random!>0.5 => ww else 0, my + parseInt((wh - my ) / 2)]
    timestamp = new Date! .getTime!
    created_at = new Date! .getTime!
    DanmakuStore.store $scope.current-video-id, {action: type, mx: mx, my:my, ex: ex, ey: ey, sy: sy, timestamp: timestamp, created_at: created_at, type: \attack}
    DanmakuPaper.throwEgg type, mx, my, ex, ey, sy
    DanmakuStats.update $scope.current-video-id, type

  eggninja.on \mousemove (e) ->
    {clientX: mx, clientY: my} = e
    sy = $(window)scrollTop!
    player.parent!parent!parent!trigger \mousemove
    crosshair.offset top: my - 100 + sy, left: mx - 100

  $scope.raise-net = (e) ->
    if !$scope.isplaying!
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#888', 30, 5000  
      return
    DanmakuPaper.protect \raise-net
    timestamp = new Date! .getTime!
    created_at = new Date! .getTime!    
    DanmakuStore.store $scope.current-video-id, {action: \raise-net, timestamp: timestamp, created_at: created_at, type: \protect}  
    DanmakuStats.update $scope.current-video-id, \net

  $scope.objection = (e, type) ->
    if !$scope.isplaying!
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#888', 30, 5000  
      return
    DanmakuPaper.protect type
    timestamp = new Date! .getTime!
    created_at = new Date! .getTime!
    DanmakuStore.store $scope.current-video-id, {action: \white-banner, timestamp: timestamp, created_at: created_at, type: \protect} 
    DanmakuStats.update $scope.current-video-id, \banner

  $scope.flower = (e, type) ->
    if !$scope.isplaying!
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#888', 30, 5000
      return
    if type=='boat' and Math.random!>0.7 => type = 'duck'  
    DanmakuPaper.protect type
    timestamp = new Date! .getTime!
    created_at = new Date! .getTime!
    DanmakuStore.store $scope.current-video-id, {action: type, timestamp: timestamp, created_at: created_at, type: \protect}
    DanmakuStats.update $scope.current-video-id, type

  $scope.render-stats = (data) ->
    root = $ \#action-stats
    [w,h] = [root.width!, root.height!]
    svg = d3.select \#action-stats .append \svg .attr \width \100% .attr \height  \100% .style \position \absolute

    data = [[i, 1 - 2*Math.random!] for x,i in[ 0 to 100]]
    x = d3.scale.linear!range [0,w] .domain [0,d3.max(data.map(-> it.0))]
    y = d3.scale.linear!range [0,h] .domain [1,-1]
    svg.append \rect .attr \x 0 .attr \y 0 .attr \width w .attr \height h/2 .style \fill \#f99
    svg.append \rect .attr \x 0 .attr \y h/2 .attr \width w .attr \height h .style \fill \#9f9
    svg.append \path .attr \class \line
      .attr \d ->
        #"M0 #{h/2}" + ([[i,d] for d,i in data]map(->"L#{x it.0} #{y it.1}")join "") + "L #{w} #{h/2}"
        "M0 #{h/2}" + (data.map(->"L#{x it.0} #{y it.1}")join "") + "L #{w} #{h/2}"
  $scope.render-stats!
  $scope.$watch 'player' -> if it => PipeService.dispatchEvent \player.init, it
  PipeService.on \player.settime ->
    console.log "play time set to #it"
    $scope.player.setCurrentTime it
