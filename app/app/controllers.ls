angular.module 'app.controllers' <[ui.state]>
.controller AppCtrl: <[$scope $location $resource $rootScope]> ++ (s, $location, $resource, $rootScope) ->

  s <<< {$location}
  s.$watch '$location.path()' (activeNavId or '/') ->
    s <<< {activeNavId}

  s.getClass = (id) ->
    if s.activeNavId.substring 0 id.length is id
      'active'
    else
      ''
.controller HackFolderCtrl: <[$scope $state HackFolder]> ++ ($scope, $state, HackFolder) ->
  # XXX turn iframes cache into a service
  $scope <<< do
    hasViewMode: -> it.match /g(doc|present|draw)/
    sortableOptions: do
      update: -> console?log \notyetupdated
    iframes: HackFolder.iframes
    docs: HackFolder.docs
    activate: HackFolder.activate
    HackFolder: HackFolder
    reload: (hackId) -> HackFolder.getIndex hackId, true ->

  $scope.$watch 'hackId' (hackId) ->
    <- HackFolder.getIndex hackId, false
    $scope.$watch 'docId' (docId) -> HackFolder.activate docId if docId
    unless $scope.docId
      if HackFolder.docs.0?id
        $state.transitionTo 'hack.doc', { docId: that, hackId: $scope.hackId }

  $scope.hackId = if $state.params.hackId => that else 's8r4l008sk'
  $scope.$watch '$state.params.docId' (docId) ->
    $scope.docId = encodeURIComponent encodeURIComponent docId if docId

.directive 'resize' <[$window]> ++ ($window) ->
  (scope) ->
    scope.width = $window.innerWidth
    scope.height = $window.innerHeight
    angular.element $window .bind 'resize' ->
      scope.$apply ->
        scope.width = $window.innerWidth
        scope.height = $window.innerHeight

.directive \ngxNoclick ->
  ($scope, element, attrs) ->
    $ element .click -> it.preventDefault!; false

.directive \ngxFinal ->
  ($scope, element, attrs) ->
    $ element .click -> it.stopPropagation();

.factory HackFolder: <[$http]> ++ ($http) ->
  iframes = {}
  docs = []
  var hackId
  do
    iframes: iframes
    collapsed: false
    docs: docs
    activate: (id, edit=false) ->
      console.log \activate id, docs
      [{type}:doc] = [d for d in docs when d.id is id]
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
          "http://ethercalc.org/#id"
      | \url => decodeURIComponent decodeURIComponent id

      if iframes[id]
          that <<< {src, mode}
      else
          iframes[id] = {src, doc, mode}

    getIndex: (id, force, cb) ->
      return cb docs if hackId is id and !force
      csv <- $http.get "http://www.ethercalc.org/_/#{id}/csv"
      .success

      hackId := id
      docs.length = 0

      entries = for line in csv.split /\n/ when line
        [url, title, ...rest] = line.split /,/
        title -= /"/g
        entry = { url, title } <<< match url
        | // ^https?:\/\/www\.ethercalc\.(?:com|org)/(.*) //
            type: \ethercalc
            id: that.1
        | // https:\/\/docs\.google\.com/document/(?:d/)?([^/]+)/ //
            type: \gdoc
            id: that.1
        | // https:\/\/docs\.google\.com/spreadsheet/ccc\?key=([^/?&]+) //
            type: \gsheet
            id: that.1
        | // https:\/\/docs\.google\.com/drawings/(?:d/)?([^/]+)/ //
            type: \gdraw
            id: that.1
        | // https:\/\/docs\.google\.com/presentation/(?:d/)?([^/]+)/ //
            type: \gpresent
            id: that.1
        | // https?:\/\/hackpad\.com/(?:.*?)-([\w]+)(\#.*)?$ //
            type: \hackpad
            id: that.1
        | // ^https?:\/\/ //
            type: \url
            id: encodeURIComponent encodeURIComponent url
            icon: "http://g.etfv.co/#{ encodeURIComponent url }"
        | otherwise => console?log \unrecognized url
        entry.icon ?= "img/#{ entry.type }.png"
        entry
      docs.splice 0, -1, ...(entries.filter -> it?)
      cb docs
