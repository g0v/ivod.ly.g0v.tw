angular.module 'app.cinema', <[ng ui.state]>
.controller CinemaCtrl: <[$scope $state]> ++ ($scope, $state) ->
  $scope.vsrc = 'https://www.youtube.com/watch?v=c64f_KHkG2s'
  $scope.$watch '$state.params.sitting' ->
    console.log \sittinghas it
