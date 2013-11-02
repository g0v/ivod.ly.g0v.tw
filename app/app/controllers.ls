poptext = (paper, text, color, size) ->
  paper.text 30, Math.floor(Math.random!*800), text .attr {'font-size': size, 'fill': color} .animate {x: 1000}, 3000

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

.controller Danmaku: <[$scope GoAngular platform]> ++ ($scope, GoAngular, platform) ->
  $scope.comments = []
  goAngular = new GoAngular $scope, \comments, { include: [\comments], exclude: [\newComment]} .initialize!
  
  paper = Raphael 10, 300, 640, 400
  $scope.$watch 'comments' (c) ->
    console.log c
    angular.forEach c, (value, index) ->
      console.log value
      poptext paper, value.text, \Black, 30
  $scope.addComment = ->
    poptext paper, value.text, \Black, 30
    timestamp = new Date!
    created_at = new Date!
    $scope.comments.push {text: $scope.newComment, timestamp: timestamp, created_at: created_at}

.controller vlist: <[$scope $http]> ++ ($scope, $http) ->
  $scope.blah = "hello world"
.controller mlylist: <[$scope $http]> ++ ($scope, $http) ->
  $scope.blah = "hello world"
