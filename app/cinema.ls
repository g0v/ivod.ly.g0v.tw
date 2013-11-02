angular.module 'app.cinema', <[ng ui.state]>
.controller CinemaCtrl: <[$scope $state LYModel DanmakuStore]> ++ ($scope, $state, LYModel, DanmakuStore) ->
  $scope.$watch 'currentVideoId' (val, old) ->
    console.log \newvid val, old
    if val
      DanmakuStore.subscribe val, ->
        console.log \got it.val!
    if old
      DanmakuStore.unsubscribe old
    # start-ticker = pop current queue every 1 sec to see if there's anything to fire

  $scope.$watch '$state.params.sitting' ->
    if !it
      return $state.transitionTo 'cinema.view' { sitting: \YS, clip: \live }
    {sitting, clip} = $state.params
    if $state.params.clip is \live
      $scope.current-video-offset = new Date '2013-11-01 08:27:30'
      $scope.current-video-id = \YS-live-2013-11-01
      $scope.vsrc = "http://ivod.ly.g0v.tw/videos/#{sitting}.webm"

    else
      videos <- LYModel.get "sittings/#{sitting}/videos" .success
      console.log \sittinghas videos
      # match clip
      $scope.vsrc = "http://youtube.com/watch?v=#{videos.0.youtube_id}"
