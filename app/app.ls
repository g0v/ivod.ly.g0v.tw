# Declare app level module which depends on filters, and services

angular.module('scroll', []).value('$anchorScroll', angular.noop)

angular.module \ly.g0v.tw <[app.controllers app.directives app.filters app.services scroll partials ui.state goinstant]>

.config <[$stateProvider $urlRouterProvider $locationProvider]> ++ ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $stateProvider
    .state 'about' do
      url: '/about'
      templateUrl: '/partials/about.html'
      controller: \About
    .state 'cinema' do
      url: '/cinema'
      templateUrl: '/partials/cinema.html'
      controller: \CinemaCtrl
    .state 'cinema.view' do
      url: '/{sitting}/{offset}'

    .state 'vlist' do
      url: '/vlist'
      templateUrl: '/partials/vlist.html'
      controller: \vlist
    .state 'mlylist' do
      url: '/mlylist'
      templateUrl: '/partials/mlylist.html'
      controller: \mlylist
    # Catch all
  $urlRouterProvider
    .otherwise('/about')

  # Without serve side support html5 must be disabled.
  $locationProvider.html5Mode true

.config <[platformProvider]> ++ (platformProvider) ->
  platformProvider.set 'https://goinstant.net/yhsiang/ivod.ly.g0v.tw'

.run <[$rootScope $state $stateParams $location]> ++ ($rootScope, $state, $stateParams, $location) ->
  $rootScope.$state = $state
  $rootScope.$stateParam = $stateParams
  $rootScope.go = -> $location.path it
  #$rootScope._build = window.global.config.BUILD
  $rootScope.$on \$stateChangeSuccess (e, {name}) ->
    window?ga? 'send' 'pageview' page: $location.$$url, title: name
  window.onYouTubeIframeAPIReady = ->
    $rootScope.$broadcast \youtube-ready
