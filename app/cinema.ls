committees = do
    IAD: \內政
    FND: \外交及國防
    ECO: \經濟
    FIN: \財政
    EDU: \教育及文化
    TRA: \交通
    JUD: \司法及法制
    SWE: \社會福利及衛生環境
    PRO: \程序
    YS: \院會
    CON: \修憲
    DIS: \紀律
format-title = ->
  if committees[it] => return "現場實況直播: #that"
  console.log it
  it = it.split \-
  name = "#{committees[it.2] or ''}#{(committees[it.3] and '聯席') or ''}"
  "第#{it.0}屆第#{it.1}會期#{name}第#{it.4 or it.3}次會議"

angular.module 'app.cinema', <[ng ui.state notifications]>
.controller CinemaCtrl: <[$scope $state $http LYModel DanmakuStore PipeService FirebaseRoot $notification]> ++ ($scope, $state, $http, LYModel, DanmakuStore, PipeService, FirebaseRoot, $notification) ->
  $scope.channelNames = committees
  $scope.$watch 'currentVideoId' (val, old) ->
    console.log \newvid val, old
    do
      <- $
      $ \iframe .load ->
        $(\iframe)[0].contentWindow.postMessage val, \*
    if val
      DanmakuStore.subscribe val, ->
        $scope.$broadcast 'danmaku_added', it.val!
        #console.log \got it.val!
    if old
      DanmakuStore.unsubscribe old
    # start-ticker = pop current queue every 1 sec to see if there's anything to fire

  PipeService.on \player.init -> $scope.mejs = it
  $scope.play-from = ->
    PipeService.dispatchEvent \player.settime, it

  FirebaseRoot.child "status/channels"
    ..on \value ->
      val = it.val!
      $scope.$apply -> $scope.channels = val
    ..on \child_changed ->
      name = it.name!
      val = it.val!
      console.log \change it.name!, it.val!
      $notification.notify '/img/logo.png', "會議快報 - #{$scope.channelNames[name]}", if val.live => "會議開始" else "會議結束"
      $scope.$apply -> $scope.channels[name] = val

  var watch-sitting
  <- $scope.$watch '$state.current.name'
  if it isnt /^cinema/
    return watch-sitting?! # cancel the watch below
  watch-sitting := $scope.$watch '$state.params.sitting' ->
    console.log \schange
    if !it
      return $state.transitionTo 'cinema.view' { sitting: \YS, clip: \live }
    {sitting, clip} = $state.params
    $scope.sitting = sitting
    $scope.title = format-title sitting
    if !$scope.recent-sitting => d3.csv \/ly-ministry.csv ->
      $scope.recent-sitting = it
      name = $scope.recent-sitting.filter(->it.sitting==sitting)
      if name.length
        $scope.$apply -> $scope.title = format-title name.0.summary

    $scope.isplaying = -> !$scope.mejs.media.paused
    if $state.params.clip is \live
      #$scope.current-video-offset = new Date '2013-11-03 08:27:30' .getTime! / 1000
      date = moment!format("YYYY-MM-DD")
      $scope.current-video-id = "#{sitting}-live-#{date}"
      $scope.vsrc = "http://ivod.ly.g0v.tw/videos/#{sitting}.webm"
      $scope.getTimestamp = -> $scope.mejs.getCurrentTime!

    else
      $http.get "http://api-beta.ly.g0v.tw/v0/collections/sittings/#{sitting}"
      .success -> $scope.detail = it
      # XXX refactor this. duplicated code from ly.g0v.tw controller
      videos <- LYModel.get "sittings/#{sitting}/videos" .success
      console.log \sittinghas videos
      # match clip
      #return if $scope.loaded is $state.params.sitting

      whole = [v for v in videos when v.firm is \whole]
      first-timestamp = if whole.0 and whole.0.first_frame_timestamp => moment that else null
      unless clip
        return $state.transitionTo 'cinema.view' { sitting: sitting, clip: whole.0.youtube_id }
      $scope.vsrc = "http://youtube.com/watch?v=#{whole.0.youtube_id}"
      # XX: verify clip
      $scope.loaded = clip
      $scope.current-video = whole.0
      $scope.current-video-id = whole.0.youtube_id
      start = first-timestamp ? moment whole.0.time
      $scope.cliptime = moment(whole.0.time)unix!
      $scope.getTimestamp = -> $scope.mejs.getCurrentTime! + moment(whole.0.time)unix!
      clips = for v in videos when v.firm isnt \whole
        { v.time, mly: v.speaker - /\s*委員/, v.length, v.thumb }

      YOUTUBE_APIKEY = 'AIzaSyDT6AVKwNjyWRWtVAdn86Q9I7HXJHG11iI'
      details <- $http.get "https://www.googleapis.com/youtube/v3/videos?id=#{whole.0.youtube_id}&key=#{YOUTUBE_APIKEY}
     &part=snippet,contentDetails,statistics,status" .success
      if details.items?0
        [_, h, m, s] = that.contentDetails.duration.match /^PT(\d+H)?(\d+M)?(\d+S)/
        duration = (parseInt(h) * 60 + parseInt m) * 60 + parseInt s
      done = false
      console.log \got details
      onPlayerReady = (event) ->
        $scope.player = event.target
      timer-id = null
      onPlayerStateChange = (event) ->
        # set waveform location indicator
        if event.data is YT.PlayerState.PLAYING and not done
          if $scope.player.nextStart
            $scope.player.seekTo that
            $scope.player.nextStart = null
          if timer-id => clearInterval timer-id
          timer = {}
            ..sec = $scope.player.getCurrentTime!
            ..start = new Date!getTime! / 1000
            ..rate = $scope.player.getPlaybackRate!
            ..now = 0
          handler = ->
            timer.now = new Date!getTime! / 1000
            $scope.$apply -> $scope.waveforms.0.current = timer.sec + (timer.now - timer.start) * timer.rate
          timer-id := setInterval ->
            handler!
          , 10000
          handler!
        else
          if timer-id => clearInterval timer-id
          timer-id := null
        return

      if $scope.player
        $scope.player.loadVideoById do
          videoId: whole.0.youtube_id
      else
        player-init = ->
          new YT.Player 'player' do
            height: '390'
            width: '640'
            videoId: whole.0.youtube_id
            events:
              onReady: onPlayerReady
              onStateChange: onPlayerStateChange
        if $scope.youtube-ready
          player-init!
        else
          $scope.$on \youtube-ready ->
            player-init!

      $scope.waveforms = []
      mkwave = (wave, speakers, time, index) ->
        waveclips = []
        for d,i in wave =>  wave[i] = d/255
        $scope.waveforms[index] = do
          id: whole[index].youtube_id
          wave: wave,
          speakers: speakers,
          current: 0,
          start: first-timestamp,
          time: time,
          cb: -> $scope.playFrom it
        #dowave wave, clips, (-> $scope.playFrom it), first-timestamp
      $scope.current-video = whole.0
      whole.forEach !(waveform, index) ->
        # XXX whole clips for committee can be just AM/PM of the same day
        start = waveform.first_frame_timestamp ? waveform.time
        day_start = +moment(start)startOf(\day)
        speakers = clips.filter -> +moment(it.time).startOf(\day) is day_start
        for clip in speakers
          clip.offset = moment(clip.time) - moment(start)
        wave <- $http.get "http://kcwu.csie.org/~kcwu/tmp/ivod/waveform/#{waveform.wmvid}.json"
        .error -> mkwave [], index
        .success
        mkwave wave, speakers, waveform.time, index
