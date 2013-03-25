# Declare app level module which depends on filters, and services

angular.module('scroll', []).value('$anchorScroll', angular.noop)

App = angular.module \app <[ui ngCookies ngResource app.controllers scroll]>

App.config <[$routeProvider $locationProvider]> ++ ($routeProvider, $locationProvider, config) ->
  $routeProvider
    .when \/:hackId templateUrl: \/partials/app/hack.html
    .when \/:hackId/:docId templateUrl: \/partials/app/hack.html
    .when \/about templateUrl: \/partials/app/about.html
    # Catch all
    .otherwise redirectTo: \/

  # Without serve side support html5 must be disabled.
  $locationProvider.html5Mode false

window.App = App
