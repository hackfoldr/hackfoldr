# Declare app level module which depends on filters, and services

angular.module('scroll', []).value('$anchorScroll', angular.noop)

App = angular.module \app <[ui ngCookies ngResource app.controllers ui.state]>

App.config <[$stateProvider $routeProvider $urlRouterProvider]> ++ ($stateProvider, $routeProvider, $urlRouterProvider) ->
  $stateProvider
    .state 'about' do
      url: '/about'
      templateUrl: '/partials/app/about.html'
    .state 'hack' do
      url: '/{hackId}'
      templateUrl: '/partials/app/hack.html'
      controller: \HackFolderCtrl
    .state 'hack.doc' do
      url: '/{docId}'
.run <[$rootScope $state $stateParams]> ++ ($rootScope, $state, $stateParams) ->
  $rootScope.$state = $state
  $rootScope.$stateParam = $stateParams
