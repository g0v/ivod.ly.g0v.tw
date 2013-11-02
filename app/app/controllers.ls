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

.controller Danmaku: <[$scope DanmakuStore $timeout DanmakuPaper]> ++ ($scope, DanmakuStore, $timout, DanmakuPaper) ->

  $scope.comments = []

  $scope.$on 'danmaku_added', (ev, danmaku)->
    now = new Date! .getTime! - 1000
    if danmaku.type == \content && danmaku.timestamp >= now
      $scope.comments.push danmaku
      DanmakuPaper.poptext danmaku.text, '#888', 30, 5000

  $scope.addComment = ->
    timestamp = $scope.getTimestamp!
    created_at = new Date! .getTime!
    if $scope.isplaying! 
      DanmakuStore.store $scope.current-video-id, {text: $scope.newComment, timestamp: timestamp, created_at: created_at, type: \content} 
    else
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#888', 30, 5000

.controller vlist: <[$scope $http]> ++ ($scope, $http) ->
  $scope.blah = "hello world"
.controller mlylist: <[$scope $http]> ++ ($scope, $http) ->
  $scope.blah = "hello world"

.controller EggNinja: <[$scope DanmakuStore DanmakuPaper]> ++ ($scope, DanmakuStore, DanmakuPaper) ->
  player = $ \#cinema-player
  crosshair = $ \#crosshair
  egg = $ \#egg
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
    {clientX: mx, clientY: my} = e
    type = <[egg shoe melon]>[parseInt(Math.random!*4)]
    sy = $(document.body)scrollTop!
    [ww, wh] = [$(document.body)width!, $(window)height!]
    [ex, ey] = [if Math.random!>0.5 => ww else 0, my + parseInt((wh - my ) / 2)]
    timestamp = $scope.getTimestamp!
    created_at = new Date! .getTime!
    #DanmakuStore.store {mx: mx, my:my, ex: ex, ey: ey, sy: sy, timestamp: timestamp, created_at: created_at, type: \action}
    #DanmakuPaper.throwEgg mx, my, ex, ey, sy

  eggninja.on \mousemove (e) ->
    {clientX: mx, clientY: my} = e
    sy = $(window)scrollTop!
    player.parent!parent!parent!trigger \mousemove
    crosshair.offset top: my - 100 + sy, left: mx - 100

  $scope.raise-net = (e) ->
    if !$scope.isplaying!
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#888', 30, 5000  
      return
    player = $ \#video-wrapper
    {top:y, left: x} = player.offset!
    [w, h] = [player.width!, player.height!]
    egg = $ \<div></div>
    egg.addClass \raise-net
    $ document.body .append egg
    egg.offset left: x, top: y + h  .animate top: y  .delay 500 .fadeOut!

  $scope.objection = (e, type) ->
    if !$scope.isplaying!
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#888', 30, 5000  
      return
    player = $ \#video-wrapper
    {top:y, left: x} = player.offset!
    #player.removeClass \saturate
    #setTimeout (-> player.addClass \saturate), 100
    egg = $ \<div></div>
    egg.addClass \white-banner .text "司法不公  政治迫害"
    $ document.body .append egg
    egg.offset left: x, top: y - 150 .animate top: y - 50  .delay 500 .fadeOut!

  $scope.flower = (e, type) ->
    if !$scope.isplaying!
      DanmakuPaper.poptext \要開始播才會可以加彈幕喔, '#888', 30, 5000
      return
    player = $ \#video-wrapper
    if type=='boat' and Math.random!>0.7 => type = 'duck'
    {clientX: mx, clientY: my} = e
    {top:y, left: x} = player.offset!

    [w, h] = [player.width!, player.height!]
    sy = $(document.body)scrollTop!
    [ww, wh] = [$(document.body)width!, $(window)height!]
    [ex, ey] = [if Math.random!>0.5 => ww else 0, my + parseInt((wh - my ) / 2)]
    egg = $ \<div></div>
    egg.addClass type
    $ document.body .append egg
    egg.offset left: x - 100, top: y + h - 200 .animate left: x + parseInt(w / 2) - 100  .delay 500 .fadeOut!

  $scope.render-stats = ->
    root = $ \#action-stats
    [w,h] = [root.width!, root.height!]
    svg = d3.select \#action-stats .append \svg .attr \width \100% .attr \height  \100% .style \position \absolute

    data = [1 - 2*Math.random! for x in[ 0 to 100]]
    x = d3.scale.linear!range [0,w] .domain [0,100]
    y = d3.scale.linear!range [0,h] .domain [1,-1]
    svg.append \rect .attr \x 0 .attr \y 0 .attr \width w .attr \height h/2 .style \fill \#f99
    svg.append \rect .attr \x 0 .attr \y h/2 .attr \width w .attr \height h .style \fill \#9f9
    svg.append \path .attr \class \line
      .attr \d ->
        console.log("M0 #{h/2}" + [[i,d] for d,i in data]map(->"L#{x it.0} #{y it.1}")join "")
        "M0 #{h/2}" + ([[i,d] for d,i in data]map(->"L#{x it.0} #{y it.1}")join "") + "L #{w} #{h/2}"
  $scope.render-stats!
