angular.module 'app.controllers' []
.controller AppCtrl: <[$scope $location $resource $rootScope]> ++ (s, $location, $resource, $rootScope) ->

  s <<< {$location}
  s.$watch '$location.path()' (activeNavId or '/') ->
    s <<< {activeNavId}

  s.getClass = (id) ->
    if s.activeNavId.substring 0 id.length is id
      'active'
    else
      ''
.controller HackFolder: <[$scope $routeParams $http]> ++ ($scope, $routeParams, $http) ->
    $scope.sortableOptions = do
        update: -> console.log \updated

    $scope.iframes = {}
    $scope.debug = (element) ->
        console.log @, $scope, element
    $scope.activate = ({type,id}:doc, edit=false) ->
        mode = if edit => \edit else \view
        src = match type
        | \gdoc =>
            "https://docs.google.com/document/d/#id/#mode"
        | \hackpad =>
            "https://hackpad.com/#id"
        | \ethercalc =>
            "http://ethercalc.com/#id"

        if $scope.iframes[id]
            that <<< {src, mode}
        else
            $scope.iframes[id] = {src, doc, mode}
        $scope.currentIframe = id

    $routeParams.hackId = 's8r4l008sk' unless $routeParams.hackId
    console.log \requ, $routeParams.hackId
    csv <- $http.get "http://www.ethercalc.com/_/#{$routeParams.hackId}/csv"
    .success
    console.log csv

    docs = for line in csv.split /\n/ when line
        [url, title, ...rest] = line.split /,/
        console.log url, title
        match url
        | // ^https?:\/\/www\.ethercalc\.com/(.*) //
            type: \ethercalc
            id: that.1
            title: title
        | // https:\/\/docs\.google\.com/document/(?:d/)?([^/]+)/ //
            type: \gdoc
            id: that.1
            title: title
        | // https:\/\/hackpad\.com/(?:.*)-([\w]+) //
            type: \hackpad
            id: that.1
            title: title
        | otherwise => console.log \unrecognized url
    console.log docs
    $scope.docs = docs.filter -> it?

.directive 'resize' <[$window]> ++ ($window) ->
  (scope) ->
    scope.width = $window.innerWidth
    scope.height = $window.innerHeight
    angular.element $window .bind 'resize' ->
      scope.$apply ->
        scope.width = $window.innerWidth
        scope.height = $window.innerHeight
