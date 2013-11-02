angular.module 'app.controllers' <[ng]>
.run <[$rootScope]> ++ ($rootScope) ->
.controller AppCtrl: <[$scope $location $rootScope $sce]> ++ (s, $location, $rootScope, $sce) ->

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
  goAngular = new GoAngular $scope, \Danmaku, { include: [\Comments]} .initialize!

  #goAngular.then (result) ->
    
  $scope.comments = []

  $scope.addComment = ->
    timestamp = new Date!
    created_at = new Date!
    $scope.comments.push {text: $scope.newComment, timestamp: timestamp, created_at: created_at}