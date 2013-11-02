angular.module 'app.directives' <[app.services ]>
.directive 'mediaelement', ($parse) ->
  restrict: 'A'
  link: (scope, element, attrs, controller) ->
    attrs.$observe 'src' ->
      if it =>
        source = $("<source type='video/youtube' src='#{it}'/>")
        element.attr \src, null
        element.append source
        scope.mediaelement = element.mediaelementplayer {}
