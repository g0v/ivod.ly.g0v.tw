angular.module 'app.directives' <[app.services ]>
.directive 'mediaelement', ($parse) ->
  restrict: 'A'
  link: (scope, element, attrs, controller) ->
    attrs.$observe 'src' ->
      console.log it
      element.mediaelementplayer!
