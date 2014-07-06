# Declare app level module which depends on filters, and services

angular.module('scroll', []).value('$anchorScroll', angular.noop)

angular.module \app <[ui app.templates app.controllers ui.state]>
.config <[$stateProvider $urlRouterProvider $locationProvider]> ++ ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $stateProvider
    .state 'about' do
      url: '/about'
      templateUrl: 'partials/about.html'
    .state 'hack' do
      url: '/{hackId:[^/]{1,}}'
      templateUrl: 'partials/hack.html'
      controller: \HackFolderCtrl
      onEnter: ->
        $ \body .addClass \hide-overflow
      onExit: ->
        $ \body .removeClass \hide-overflow
    .state 'hack.index' do
      url: '/__index'
    .state 'hack.doc' do
      url: '/{docId}'

  $urlRouterProvider
    .otherwise('/about')

  $locationProvider.html5Mode true

.run <[$rootScope $state $stateParams $location]> ++ ($rootScope, $state, $stateParams, $location) ->
  $rootScope.$state = $state
  $rootScope.$stateParam = $stateParams
  $rootScope.go = -> $location.path it
  $rootScope._build = require 'config.jsenv' .BUILD
  $rootScope.$on \$stateChangeSuccess (e, {name}) ->
    window?ga? 'send' 'pageview' page: $location.$$url, title: name
  $rootScope.safeApply = ($scope, fn) ->
    phase = $scope.$root.$$phase
    if (phase is '$apply' || phase is '$digest')
      fn?!
    else
      $scope.$apply fn
