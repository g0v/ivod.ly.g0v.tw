angular.module 'app.directives' <[app.services ]>
.directive 'mediaelement', ($parse) ->
  restrict: 'A'
  link: (scope, element, attrs, controller) ->
    attrs.$observe 'src' ->
      if it =>
        type = if it is /youtube/ => 'youtube' else 'webm'
        source = $("<source type='video/#type' src='#{it}'/>")
        element.attr \src, null
        element.append source
        if type is 'webm'
          m3u8 = it.replace // /videos/(.*?).webm // '/hls/$1/index.m3u8'
          source = $("<source type='video/m3u8' src='#{m3u8}'/>")
          element.attr \src, null
          element.append source
        scope.player = new MediaElementPlayer element
        #scope.mediaelement = element.mediaelementplayer {}


.directive 'whenScrolled' ->
  (scope, elm, attr) ->
    raw = elm[0];
    <- elm.bind 'scroll'
    if (raw.scrollTop + raw.offsetHeight >= raw.scrollHeight)
      scope.$apply attr.whenScrolled
