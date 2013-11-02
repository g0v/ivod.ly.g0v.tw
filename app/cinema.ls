angular.module 'app.cinema', <[ng ui.state]>
.controller CinemaCtrl: <[$scope $state]> ++ ($scope, $state) ->
  $scope.$watch '$state.params.sitting' ->
    console.log \sittinghas it
