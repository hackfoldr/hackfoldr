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
  $scope <<< do
    hasViewMode: -> it.match /g(doc|present|draw)/
    sortableOptions: do
      update: -> console?log \notyetupdated
    iframes: HackFolder.iframes
    docs: HackFolder.docs
    tree: HackFolder.tree
    activate: HackFolder.activate
    HackFolder: HackFolder
    onIframeLoad: (doc) -> ->
      {location} = @contentWindow
      console?log \location location, doc.id
      # XXX: parse the location, if the id is different, prompt for creating a
      # new entry.  also detect for first iframe load

    debug: -> console?log it, @
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
  tree = []
  var hackId
  self = do
    iframes: iframes
    docs: docs
    tree: tree
    activate: (id, edit=false) ->
      [{type}:doc] = [d for d in docs when d.id is id]
      for t in tree
        if t?children?map (.id)
          t.expand = true if id in that
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
          "https://ethercalc.org/#id"
      | \url => decodeURIComponent decodeURIComponent id
      | otherwise => ''

      if iframes[id]
          that <<< {src, mode}
      else
          iframes[id] = {src, doc, mode}

    getIndex: (id, force, cb) ->
      return cb docs if hackId is id and !force
      csv <- $http.get "https://www.ethercalc.org/_/#{id}/csv"
      .success

      hackId := id
      docs.length = 0

      var folder-title
      entries = for line in csv.split /\n/ when line
        [url, title, opts, tags, ...rest] = line.split /,/
        title -= /^"|"$/g
        opts -= /^"|"$/g if opts
        opts.=replace /""/g '"' if opts
        tags -= /^"|"$/g if tags
        [_, prefix, url] = url.match /^"?(\s*)(\S+)?"?$/
        entry = { url, title, indent: prefix.length, opts: try JSON.parse opts ? '{}' } <<< match url
        | void
            unless folder-title
              if title
                folder-title = title
                title = null
            title: title
            type: \dummy
            id: \dummy
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
        | // https?:\/\/hackpad\.com/(?:.*?-)?([\w]+)(\#.*)?$ //
            type: \hackpad
            id: that.1
        | // ^(https?:\/\/[^/]+) //
            type: \url
            id: encodeURIComponent encodeURIComponent url
            icon: "http://g.etfv.co/#{ that.1 }"
        | otherwise => console?log \unrecognized url

        if entry.type is \dummy and !entry.title?length
          null
        else
          {icon: "img/#{ entry.type }.png"} <<< entry

      docs.splice 0, docs.length, ...(entries.filter -> it?)
      last-parent = 0
      nested = for entry, i in docs
        if i > 0 and entry.indent
          docs[last-parent]
            ..children ?= []
              ..push entry
          null
        else
          last-parent = i
          entry <<< {expand: entry.opts?expand ? false}
      tree.splice 0, tree.length, ...(nested.filter -> it?)
      self.folder-title = folder-title
      cb docs
