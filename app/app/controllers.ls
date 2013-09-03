angular.module 'app.controllers' <[ui.state ngCookies]>
.controller AppCtrl: <[$scope $state $rootScope $timeout]> ++ ($scope, $state, $rootScope, $timeout) ->
  $scope.$watch '$state.current.name' ->
    $scope.irc-enabled = true if it is \irc

  <- $timeout _, 10s * 1000ms
  $rootScope.hideGithubRibbon = true

.controller HackFolderCtrl: <[$scope $state $cookies HackFolder]> ++ ($scope, $state, $cookies, HackFolder) ->
  $scope <<< do
    hasViewMode: -> it.match /g(doc|present|draw)/
    sortableOptions: do
      update: -> console?log \notyetupdated
    iframes: HackFolder.iframes
    docs: HackFolder.docs
    tree: HackFolder.tree
    godoc: (doc) ->
      if doc.opts?target == '_blank'
        window.open doc.url, doc.id
        return true
      else if doc.url.match /(https?:)?\/\/[^/]*(github|facebook)\.com/
        window.open doc.url, doc.id
        return true
      else
        $scope.go "/#{ $scope.hackId }/#{ decodeURIComponent doc.id }"
    open: (doc) ->
      window.open doc.url, doc.id
      return false
    activate: HackFolder.activate
    saveBtn: void
    saveModalOpts: dialogFade: true
    saveModalOpen: false
    showSaveModal: (show,rm,e)->
      $scope.saveModalOpen = show
      if e => $scope.saveBtn = $ e.target
      if rm =>
        $cookies.savebtn = \consumed
        if $scope.saveBtn => $scope.saveBtn.fadeOut 1000
    showSaveBtn: ->
      $cookies.savebtn != \consumed
    HackFolder: HackFolder
    iframeCallback: (doc) -> (status) -> $scope.$apply ->
      console?log \iframecb status, doc
      $state.current.title = "#{doc.title} – hack.g0v.tw"
      if status is \fail
        doc.noiframe = true
      else
        doc.noiframe = false
      doc.iframeunsure = true if status is \unsure

    debug: -> console?log it, @
    reload: (hackId) -> HackFolder.getIndex hackId, true ->

  $scope.pgname = $state.params.pgname
  $scope.$watch 'hackId' (hackId) ->
    <- HackFolder.getIndex hackId, false
    $scope.$watch 'docId' (docId) -> HackFolder.activate docId if docId
    unless $scope.docId
      if HackFolder.docs.0?id
        if $state.params.pgname != '__index'
          $state.transitionTo 'hack.doc', { docId: that, hackId: $scope.hackId}
        else
          $state.transitionTo 'hack.doc', { hackId: $scope.hackId,pgname:$scope.pgname}


  $scope.hackId = if $state.params.hackId => that else 'g0v-hackath4n'
  $scope.$watch '$state.params.docId' (docId) ->
    $scope.docId = encodeURIComponent encodeURIComponent docId if docId

.directive 'resize' <[$window]> ++ ($window) ->
  (scope, element, attrs) ->
    refresh-size = ->
      scope.width = $window.innerWidth
      scope.height = $window.innerHeight
      scope.content-height = $window.innerHeight - $ element .offset!top

    angular.element $window .bind 'resize' ->
      scope.$apply refresh-size

    refresh-size!

.directive 'ngxIframe' <[$parse]> ++ ($parse) ->
  link: ($scope, element, attrs) ->
    cb = ($parse attrs.ngxIframe) $scope
    dispatch = (iframe, loading) ->
      ok = !try
        iframe.location ~= \about:blank
      # access denied, meaning the iframe is loaded. wait for .load to fire
      if loading and $.browser.mozilla
        # check if the failure is actually XFO denied. this doesn't work
        # req = $.ajax do
        #   type: \OPTION
        #   url: attrs.src
        #   success: ->
        #     console.log \done
        #     req.getAllResponseHeaders!
        #   error: (request, textStatus, errorThrown) ->
        #     console.log \err textStatus, request.getAllResponseHeaders!
        #     console.log request
        cb \unsure
      else
        cb if ok => \ok else \fail

    var fail
    $ element .load ->
      clearTimeout fail
      dispatch @contentWindow, true

    fail = setTimeout (->
      dispatch element[0].contentWindow
    ), 5000ms
.directive \ngxNoclick ->
  ($scope, element, attrs) ->
    $ element .click -> it.preventDefault!; false

.directive 'ngxClickMeta' <[$parse]> ++ ($parse) ->
  link: ($scope, element, attrs) ->
    cb = $parse attrs.ngxClickMeta

    is-meta = if navigator.appVersion.match /Win/
      -> it.ctrlKey
    else
      -> it.metaKey

    $ element .click (e) ->
      if is-meta e
        unless cb $scope
          e.preventDefault!
          return false
      return

.directive \ngxFinal ->
  ($scope, element, attrs) ->
    $ element .click -> it.stopPropagation();

.directive \scrollbar <[$window]> ++ ($window) ->
  (scope, element, attrs) ->
    has-scrollbar = ->
      $index = $('.index')
      scope.has-scrollbar = $index.get(0).scrollHeight > $window.innerHeight - $('.navbar').height()
    angular.element $window .bind \resize ->
      scope.$apply has-scrollbar
    scope.$watch 'docs' has-scrollbar
    has-scrollbar()

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
          "https://docs.google.com/document/d/#id/#mode?pli=1&overridemobile=true"
      | \gsheet =>
          "https://docs.google.com/spreadsheet/ccc?key=#id"
      | \gpresent =>
          "https://docs.google.com/presentation/d/#id/#mode"
      | \gdraw =>
          "https://docs.google.com/drawings/d/#id/#mode"
      | \gsheet =>
          "https://docs.google.com/spreadsheet/ccc?key=#id"
      | \hackpad =>
        "https://#{ doc.site ? '' }hackpad.com/#{id}"
      | \ethercalc =>
          "https://ethercalc.org/#id"
      | \url => decodeURIComponent decodeURIComponent id
      | otherwise => ''

      src += doc.hashtag if doc.hashtag

      if iframes[id]
          that <<< {src, mode}
      else
          iframes[id] = {src, doc, mode}

    getIndex: (id, force, cb) ->
      return cb docs if hackId is id and !force
      retry = 0
      doit = ~>
        csv <~ $http.get "https://www.ethercalc.org/_/#{id}/csv"
        .error -> return if ++retry > 3; setTimeout doit, 1000ms
        .success

        hackId := id
        docs.length = 0
        @load-csv csv, cb
      doit!

    load-csv: (csv, cb) ->
      var folder-title
      csv -= /^\"?#.*\n/gm
      entries = for line in csv.split /\n/ when line
        [url, title, opts, tags, ...rest] = line.split /,/
        title -= /^"|"$/g
        opts -= /^"|"$/g if opts
        opts.=replace /""/g '"' if opts
        tags -= /^"|"$/g if tags
        [_, prefix, url, hashtag] = url.match /^"?(\s*)(\S+?)?(#\S+?)?\s*"?$/
        entry = { hashtag, url, title, indent: prefix.length, opts: try JSON.parse opts ? '{}' } <<< match url
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
        | // https?:\/\/(\w+\.)?hackpad\.com/(?:.*?-)?([\w]+)(\#.*)?$ //
            type: \hackpad
            site: that.1
            id: that.2
        | // ^(https?:\/\/[^/]+) //
            type: \url
            id: encodeURIComponent encodeURIComponent url
            icon: "http://g.etfv.co/#{ that.1 }"
        | otherwise => console?log \unrecognized url

        if entry.type is \dummy and !entry.title?length
          null
        else
          {icon: "/img/#{ entry.type }.png"} <<< entry <<< do
            tags: (entry.opts?tags ? []) ++ ((tags?split \,) ? [])
              .filter -> it.length
              .map (tag) ->
                [_, content, c, ...rest] = tag.match /^(.*?)(?::(.*))?$/
                {content, class: c ? 'warning'}

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
          entry
      nested .= filter -> it?
      nested .= map ->
        if it.children
          it.expand = it.opts?expand ? it.children.length < 5
        it
      tree.splice 0, tree.length, ...nested
      self.folder-title = folder-title
      cb docs