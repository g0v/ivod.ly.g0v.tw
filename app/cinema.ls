angular.module 'app.cinema', <[ng ui.state]>
.controller CinemaCtrl: <[$scope $state LYModel]> ++ ($scope, $state, LYModel) ->
  $scope.$watch '$state.params.sitting' ->
    if !it
      return $state.transitionTo 'cinema.view' { sitting: \YS, clip: \live }
    if $state.params.clip is \live
      $scope.current-video-offset = new Date '2013-11-01 08:27:30'
      $scope.vsrc = "http://ivod.ly.g0v.tw/videos/#{$state.params.sitting}.webm"
    else
      videos <- LYModel.get "sittings/#{$state.params.sitting}/videos" .success
      console.log \sittinghas videos
      $scope.vsrc = "http://youtube.com/watch?v=#{videos.0.youtube_id}"
