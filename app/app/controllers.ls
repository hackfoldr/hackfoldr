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
  # XXX turn iframes cache into a service
  unless $scope.iframes
    $scope <<< do
      hasViewMode: -> it.match /g(doc|present|draw)/
      sortableOptions: do
        update: -> console.log \updated

      iframes: {}
      debug: (element) ->
        console.log @, $scope, element
      activate: (id, edit=false) ->
        [{type}:doc] = [d for d in $scope.docs when d.id is id]
        mode = if edit => \edit else \view
        src = match type
        | \gdoc =>
            "https://docs.google.com/document/d/#id/#mode"
        | \gsheet =>
            "https://docs.google.com/spreadsheet/ccc?key=#id"
        | \gpresent =>
            "https://docs.google.com/presentation/d/#id/#mode"
        | \gdraw =>
            "https://docs.google.com/drawings/d/#id/#mode"
        | \gsheet =>
            "https://docs.google.com/spreadsheet/ccc?key=#id"
        | \hackpad =>
            "https://hackpad.com/#id"
        | \ethercalc =>
            "http://ethercalc.com/#id"

        if $scope.iframes[id]
            that <<< {src, mode}
        else
            $scope.iframes[id] = {src, doc, mode}
        $scope.currentIframe = id

    $scope.$watch 'hackId' ->
      csv <- $http.get "http://www.ethercalc.com/_/#{$scope.hackId}/csv"
      .success

      docs = for line in csv.split /\n/ when line
        [url, title, ...rest] = line.split /,/
        match url
        | // ^https?:\/\/www\.ethercalc\.com/(.*) //
            type: \ethercalc
            id: that.1
            title: title
        | // https:\/\/docs\.google\.com/document/(?:d/)?([^/]+)/ //
            type: \gdoc
            id: that.1
            title: title
        | // https:\/\/docs\.google\.com/spreadsheet/ccc\?key=([^/?&]+) //
            type: \gsheet
            id: that.1
            title: title
        | // https:\/\/docs\.google\.com/drawings/(?:d/)?([^/]+)/ //
            type: \gdraw
            id: that.1
            title: title
        | // https:\/\/docs\.google\.com/presentation/(?:d/)?([^/]+)/ //
            type: \gpresent
            id: that.1
            title: title
        | // https:\/\/hackpad\.com/(?:.*)-([\w]+) //
            type: \hackpad
            id: that.1
            title: title
        | otherwise => console.log \unrecognized url
      $scope.docs = docs.filter -> it?
      console.log \act $scope.docId
      $scope.$watch 'docId' (docId) -> $scope.activate docId

    $scope.hackId = $routeParams.hackId ? 's8r4l008sk'
    if $routeParams.docId
      $scope.docId = $routeParams.docId


.directive 'resize' <[$window]> ++ ($window) ->
  (scope) ->
    scope.width = $window.innerWidth
    scope.height = $window.innerHeight
    angular.element $window .bind 'resize' ->
      scope.$apply ->
        scope.width = $window.innerWidth
        scope.height = $window.innerHeight
