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
        scope.mediaelement = element.mediaelementplayer {}
