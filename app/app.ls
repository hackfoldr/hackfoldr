# Declare app level module which depends on filters, and services

angular.module('scroll', []).value('$anchorScroll', angular.noop)

angular.module \app <[ui app.templates app.controllers ct.ui.router.extras ui.router.stateHelper]>
.config <[stateHelperProvider $urlRouterProvider $locationProvider]> ++ (stateHelperProvider, $urlRouterProvider, $locationProvider) ->
  stateHelperProvider.setNestedState do
    name: 'about'
    url: '/about'
    template-url: 'partials/about.html'
  stateHelperProvider.setNestedState do
    name: 'hack'
    url: '/{hackId:[^/]{1,}}'
    template-url: 'partials/hack.html'
    resolve:
      hackId: <[$stateParams]> ++ (.hackId)
    controller: 'HackFolderCtrl'
    onEnter: ->
      $ \body .addClass \hide-overflow
    onExit: ->
      $ \body .removeClass \hide-overflow
    children:
      * name: 'index'
        url: '/__index'
      * name: 'doc'
        url: '/{docId}'
        views:
          'hack-index':
            template-url: 'partials/hack-index.html'
          'pad-container':
            template-url: 'partials/pad-container.html'

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
  $rootScope.$safeApply = ($scope, fn) ->
    phase = $scope.$root.$$phase
    if (phase is '$apply' || phase is '$digest')
      fn?!
    else
      $scope.$apply fn
